#!/usr/bin/env python3
"""Normal-workflow robustness cases for mature-leaf soluble/starch carbon."""

import argparse
import csv
import importlib.util
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BASE_PATH = ROOT / "tests" / "validation" / "run_single_leaf_carbon.py"
SPEC = importlib.util.spec_from_file_location("leaf_carbon_base", BASE_PATH)
base = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(base)


def build_case(label, cp, initial_fraction, steps, light_hours=14,
               input_par=1000, switch=False,
               maximum_starch_mobilization_rate=0.10):
    values = base.generated_inputs(cp)
    climate_name = "Metdata_singleLeafCarbon.%s.csv" % label
    options, params, initial = values[5:]
    options_name = "model.options.singleLeafCarbon.%s.json" % label
    params_name = "plant.parameters.singleLeafCarbon.%s.json" % label
    initial_name = "initial.conditions.singleLeafCarbon.%s.json" % label
    options["name"] = options_name[:-5]
    module = options["category"]["module_configuration"]
    module["FILE_NAME_PLANT_PARAMETERS"] = params_name
    module["FILE_NAME_INITIAL_CONDITIONS"] = initial_name
    options["category"]["environment_climate"]["climate_file"] = climate_name
    options["category"]["location"]["latitude_N"] = (
        40.0 if light_hours <= 10 else -37.0
    )
    options["category"]["simulation_time"]["halt"] = (steps + 23) // 24
    boundary = options["category"]["single_leaf_carbon_test"]
    boundary.update({
        "imposedPhloemSugarSwitchEnabled": switch,
        "imposedPhloemSugarHighStartStep": 48,
        "imposedPhloemSugarLowReturnStep": 120,
        "imposedPhloemSugarLowMassFraction": 0.05,
        "imposedPhloemSugarHighMassFraction": 0.20,
    })
    params["name"] = params_name[:-5]
    params["category"]["leaf-carbon"][
        "maximumStarchMobilizationRatePerHour"
    ] = maximum_starch_mobilization_rate
    initial["name"] = initial_name[:-5]
    initial["category"]["leaf"]["initialStarchFractionOfLeafNSC"] = initial_fraction
    return (
        options_name, params_name, initial_name, climate_name,
        options, params, initial, steps, input_par,
    )


def run_case(label, specification, generated):
    options_name, params_name, initial_name, climate_name = specification[:4]
    options, params, initial, steps, input_par = specification[4:]
    paths = (
        base.SCENARIOS / options_name,
        base.SCENARIOS / params_name,
        base.SCENARIOS / initial_name,
    )
    base.write_json(paths[0], options)
    base.write_json(paths[1], params)
    base.write_json(paths[2], initial)
    generated.extend(paths)
    climate_path = base.INPUT / climate_name
    with climate_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([
            "station", "year", "day", "hour", "temp", "rh",
            "totalRadiation", "CO2", "wind", "soilWater_potential",
            "soilWater_content", "rainfall",
        ])
        for index in range(steps + 1):
            day = 1 + index // 24
            hour = index % 24
            radiation = input_par if 5 <= hour < 19 else 0
            writer.writerow([
                1, 2021, day, hour, 25, 0.70, radiation, 400, 1.2,
                "-0.10, -0.10, -0.10, -0.10",
                "0.25, 0.25, 0.25, 0.25", 0,
            ])
    generated.append(climate_path)
    log_path = base.ARTIFACTS / ("robust_%s.log" % label)
    command = [
        "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
        str(steps), options_name,
    ]
    with log_path.open("w", encoding="utf-8") as log:
        result = subprocess.run(
            command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
            timeout=300,
        )
    if result.returncode != 0:
        raise RuntimeError("%s failed with exit %d; see %s" % (
            label, result.returncode, log_path,
        ))
    log_text = log_path.read_text(encoding="utf-8", errors="replace")
    if "Unexpected Exception" in log_text or "Exception in run()" in log_text:
        raise RuntimeError("%s reported a GroIMP exception; see %s" % (
            label, log_path,
        ))
    rows = base.read_diagnostics(
        ROOT / "Model_output" / ("singleLeafCarbon_%s" % label)
    )
    for row in rows:
        if abs(base.finite(row["leafMaintenanceFromPhloemMgC"])) > 1.0e-10:
            raise AssertionError("%s: imposed boundary funded maintenance" % label)
        if abs(base.finite(row["leafCarbonClosureResidualMgC"])) > 1.0e-7:
            raise AssertionError("%s: carbon closure failed" % label)
        if base.finite(row["leafSolubleCarbonMgC"]) < -1.0e-8:
            raise AssertionError("%s: negative soluble carbon" % label)
        if base.finite(row["leafStarchCarbonMgC"]) < -1.0e-8:
            raise AssertionError("%s: negative starch carbon" % label)
        if int(row["leafCarbonCommitCount"]) > int(row["step"]):
            raise AssertionError("%s: more than one pool commit per step" % label)
        if int(row["leafCarbonPreparationCount"]) > int(row["step"]):
            raise AssertionError("%s: more than one preparation per step" % label)
    return rows, log_path


def dawn_starch(rows):
    trajectory = []
    for index in range(len(rows) - 1):
        if (rows[index]["isPhotoperiodLight"].lower() == "false"
                and rows[index + 1]["isPhotoperiodLight"].lower() == "true"):
            trajectory.append(base.finite(rows[index]["leafStarchCarbonMgC"]))
    return trajectory


def write_rows(name, rows):
    path = base.ARTIFACTS / name
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    return path


def mean(rows, key):
    return sum(base.finite(row[key]) for row in rows) / max(1, len(rows))


def accepted_pool_changes(all_rows, selected_rows, label):
    """Return accepted S+T changes and verify the step flux identity."""
    by_step = {int(row["step"]): row for row in all_rows}
    changes = []
    for row in selected_rows:
        previous = by_step.get(int(row["step"]) - 1)
        if previous is None:
            continue
        change = (base.finite(row["leafTotalNSCMgC"])
                  - base.finite(previous["leafTotalNSCMgC"]))
        expected = (max(0.0, base.finite(row["carbonAssimilation"]))
                    - base.finite(row["leafActualLoadingMgC"])
                    - base.finite(row["leafLocalSolubleDemandMgC"])
                    - base.finite(row["leafCarbonMobilizationCostMgC"]))
        if abs(change - expected) > 1.0e-7:
            raise AssertionError(
                "%s step %s: pool change %s != accepted external fluxes %s"
                % (label, row["step"], change, expected)
            )
        changes.append({"netPoolChange": change})
    if not changes:
        raise AssertionError("%s had no consecutive accepted pool states" % label)
    return changes


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--keep-configs", action="store_true",
        help="retain generated scenario and climate inputs for interactive Xrun use",
    )
    args = parser.parse_args(argv)
    base.ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    sensitivity_rows = []
    logs = []
    try:
        for fraction in (0.1, 0.5, 0.8):
            trajectories = {}
            for cp in (0.05, 0.20):
                label = "init%03d_cp%03d" % (round(fraction * 100), round(cp * 1000))
                rows, log_path = run_case(
                    label, build_case(label, cp, fraction, 7 * 24), generated
                )
                logs.append(log_path)
                trajectory = dawn_starch(rows)
                if len(trajectory) < 7:
                    raise AssertionError("%s: fewer than seven dawn samples" % label)
                trajectories[cp] = trajectory[:7]
                for day, value in enumerate(trajectory[:7], 1):
                    sensitivity_rows.append({
                        "initialStarchFraction": fraction,
                        "Cp": cp,
                        "day": day,
                        "dawnStarchMgC": value,
                    })
            if trajectories[0.20][-1] <= trajectories[0.05][-1]:
                raise AssertionError(
                    "high Cp did not produce greater day-7 dawn starch at init=%s"
                    % fraction
                )
        sensitivity_path = write_rows(
            "single_leaf_carbon_initial_sensitivity.csv", sensitivity_rows
        )

        switch_label = "cpSwitch"
        switch_rows, log_path = run_case(
            switch_label,
            build_case(switch_label, 0.05, 0.5, 8 * 24, switch=True),
            generated,
        )
        logs.append(log_path)
        low1 = [row for row in switch_rows if int(row["step"]) < 48]
        high = [row for row in switch_rows if 48 <= int(row["step"]) < 120]
        low2 = [row for row in switch_rows if int(row["step"]) >= 120]
        if not mean(low1, "leafActualLoadingMgC") > mean(high, "leafActualLoadingMgC"):
            raise AssertionError("Cp switch did not suppress loading in the high period")
        if not mean(low2, "leafActualLoadingMgC") > mean(high, "leafActualLoadingMgC"):
            raise AssertionError("loading did not recover after return to low Cp")
        if base.finite(high[-1]["leafSolubleCarbonMgC"]) <= base.finite(high[0]["leafSolubleCarbonMgC"]):
            raise AssertionError("soluble carbon did not rise across the high-Cp period")
        switch_summary = [{
            "period": name,
            "meanLoadingMgC": mean(rows, "leafActualLoadingMgC"),
            "meanSolubleMgC": mean(rows, "leafSolubleCarbonMgC"),
            "starchDegradationMgC": sum(base.finite(row["leafStarchDegradationMgC"]) for row in rows),
            "overflowSynthesisMgC": sum(base.finite(row["leafOverflowStarchSynthesisMgC"]) for row in rows),
        } for name, rows in (("low1", low1), ("high", high), ("low2", low2))]
        switch_path = write_rows("single_leaf_carbon_cp_switch.csv", switch_summary)

        photoperiod_results = {}
        for label, light_hours, input_par in (
            ("photo10h", 10, 1000), ("photo14h", 14, 1000),
            ("cloudyAbove14h", 14, 100), ("cloudyBelow14h", 14, 10),
        ):
            rows, log_path = run_case(
                label,
                build_case(
                    label, 0.10, 0.5, 48, light_hours, input_par,
                    maximum_starch_mobilization_rate=10.0,
                ),
                generated,
            )
            logs.append(log_path)
            photoperiod_results[label] = rows
        cloudy_summary = []
        for label in ("photo14h", "cloudyAbove14h", "cloudyBelow14h"):
            light_rows = [
                row for row in photoperiod_results[label]
                if row["isPhotoperiodLight"].lower() == "true"
                and int(row["leafCarbonCommitCount"]) > 0
            ]
            if not light_rows:
                raise AssertionError("%s had no photoperiod-light rows" % label)
            if max(base.finite(row["leafStarchDegradationMgC"])
                   for row in light_rows) > 1.0e-10:
                raise AssertionError("%s triggered nocturnal degradation" % label)
            for row in light_rows:
                assimilation = base.finite(row["carbonAssimilation"])
                demand = base.finite(row["leafMaintenanceDemandMgC"])
                expected = max(0.0, -assimilation)
                if abs(demand - expected) > 1.0e-7:
                    raise AssertionError(
                        "%s double-counted photoperiod respiration: A=%s M=%s"
                        % (label, assimilation, demand)
                    )
            cloudy_summary.append({
                "case": label,
                "radiation": mean(light_rows, "globalRadiation"),
                "meanCarbonAssimilationMgC": mean(light_rows, "carbonAssimilation"),
                "meanMaintenanceDemandMgC": mean(light_rows, "leafMaintenanceDemandMgC"),
                "meanMaintenanceFromSolubleMgC": mean(light_rows, "leafMaintenanceFromSolubleMgC"),
                "meanMaintenanceFromStarchMgC": mean(light_rows, "leafMaintenanceFromStarchMgC"),
                "meanMaintenanceFromPhloemMgC": mean(light_rows, "leafMaintenanceFromPhloemMgC"),
                "meanNetPoolChangeMgC": mean(
                    accepted_pool_changes(
                        photoperiod_results[label], light_rows, label
                    ), "netPoolChange"
                ),
            })
        above_assimilation = cloudy_summary[1]["meanCarbonAssimilationMgC"]
        below_assimilation = cloudy_summary[2]["meanCarbonAssimilationMgC"]
        if above_assimilation <= 0.0:
            raise AssertionError("cloudy-above-compensation fixture was not positive")
        if below_assimilation >= 0.0:
            raise AssertionError("cloudy-below-compensation fixture was not negative")
        night_rows = [
            row for row in photoperiod_results["photo14h"]
            if row["isPhotoperiodLight"].lower() == "false"
            and base.finite(row["globalRadiation"]) <= 0.0
            and int(row["leafCarbonCommitCount"]) > 0
        ]
        cloudy_summary.append({
            "case": "trueNight",
            "radiation": mean(night_rows, "globalRadiation"),
            "meanCarbonAssimilationMgC": mean(night_rows, "carbonAssimilation"),
            "meanMaintenanceDemandMgC": mean(night_rows, "leafMaintenanceDemandMgC"),
            "meanMaintenanceFromSolubleMgC": mean(night_rows, "leafMaintenanceFromSolubleMgC"),
            "meanMaintenanceFromStarchMgC": mean(night_rows, "leafMaintenanceFromStarchMgC"),
            "meanMaintenanceFromPhloemMgC": mean(night_rows, "leafMaintenanceFromPhloemMgC"),
            "meanNetPoolChangeMgC": mean(
                accepted_pool_changes(
                    photoperiod_results["photo14h"], night_rows, "trueNight"
                ), "netPoolChange"
            ),
        })
        if cloudy_summary[-1]["meanMaintenanceDemandMgC"] <= 0.0:
            raise AssertionError("true night did not use mature-leaf maintenance")
        cloudy_path = write_rows("single_leaf_carbon_cloudy_accounting.csv", cloudy_summary)
        first_dark = {}
        for label in ("photo10h", "photo14h"):
            candidates = [
                row for row in photoperiod_results[label]
                if (row["isPhotoperiodLight"].lower() == "false"
                    and base.finite(row["hoursUntilExpectedDawn"]) > 1.0)
            ]
            row = candidates[0]
            first_dark[label] = (
                base.finite(row["leafPotentialStarchDegradationMgC"])
                / max(1.0e-12, base.finite(row["leafStarchCarbonMgC"]))
            )
        if first_dark["photo10h"] >= first_dark["photo14h"]:
            raise AssertionError("longer night did not reduce dawn-paced fractional capacity")
        photo_path = write_rows("single_leaf_carbon_photoperiod.csv", [
            {"case": key, "firstDarkCapacityFraction": value}
            for key, value in sorted(first_dark.items())
        ])

        print("PASS: normal-workflow leaf-carbon robustness suite")
        print("initialSensitivity=%s" % sensitivity_path)
        print("cpSwitch=%s" % switch_path)
        print("photoperiod=%s" % photo_path)
        print("cloudyAccounting=%s" % cloudy_path)
        for log_path in logs:
            print("log=%s" % log_path)
        return 0
    finally:
        if not args.keep_configs:
            for path in generated:
                if path.is_file():
                    path.unlink()


if __name__ == "__main__":
    sys.exit(main())
