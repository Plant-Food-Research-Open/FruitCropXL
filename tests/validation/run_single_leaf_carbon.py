#!/usr/bin/env python3
"""Run the deterministic mature single-leaf imposed-phloem experiment."""

import argparse
import csv
import json
import math
import os
import subprocess
import sys
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCENARIOS = ROOT / "Model_scenarios"
INPUT = ROOT / "Model_input"
ARTIFACTS = ROOT / "tests" / "validation" / "leaf_carbon_single_leaf"
TREATMENTS = (0.05, 0.10, 0.20)
STEPS = 7 * 24


def load_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def write_climate(path):
    header = [
        "station", "year", "day", "hour", "temp", "rh", "totalRadiation",
        "CO2", "wind", "soilWater_potential", "soilWater_content", "rainfall",
    ]
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(header)
        for index in range(STEPS + 1):
            day = 1 + index // 24
            hour = index % 24
            radiation = 1000 if 5 <= hour < 19 else 0
            writer.writerow([
                1, 2021, day, hour, 25, 0.70, radiation, 400, 1.2,
                "-0.10, -0.10, -0.10, -0.10",
                "0.25, 0.25, 0.25, 0.25", 0,
            ])


def generated_inputs(cp, loading_cap_rate=0.0):
    suffix = "%03d" % round(cp * 1000)
    options_name = "model.options.singleLeafCarbon.cp%s.json" % suffix
    params_name = "plant.parameters.singleLeafCarbon.json"
    initial_name = "initial.conditions.singleLeafCarbon.json"
    climate_name = "Metdata_singleLeafCarbon_validation.csv"
    options = load_json(SCENARIOS / "model.options.singleLeaf.json")
    options["name"] = options_name[:-5]
    categories = options["category"]
    module = categories["module_configuration"]
    module["FILE_NAME_PLANT_PARAMETERS"] = params_name
    module["FILE_NAME_INITIAL_CONDITIONS"] = initial_name
    module["leafCarbonModel"] = "solubleStarch"
    module["leafPhotosynthesisCarbonFeedback"] = "none"
    functionality = categories["model_functionality"]
    functionality["calcCarbonAllocation"] = True
    functionality["useCTRAM"] = False
    functionality["leafSenescence"] = False
    categories["simulation_time"]["halt"] = 7
    categories["environment_climate"]["climate_file"] = climate_name
    output = categories["output_controls"]
    output["outputLeafGrowthDiagnostics"] = True
    output["debugLeafExpansionSampleEvery"] = 1
    categories["single_leaf_carbon_test"] = {
        "singleLeafCarbonTest": True,
        "imposePhloemSugar": True,
        "imposedPhloemSugarMassFraction": cp,
        "imposedPhloemSugarSwitchEnabled": False,
        "imposedPhloemSugarHighStartStep": 48,
        "imposedPhloemSugarLowReturnStep": 120,
        "imposedPhloemSugarLowMassFraction": 0.05,
        "imposedPhloemSugarHighMassFraction": 0.20,
    }

    params = load_json(SCENARIOS / "plant.parameters.FJ.json")
    params["name"] = params_name[:-5]
    plant_carbon = params["category"]["plant-carbon"]
    plant_carbon["sourceLoading_b"] = 35
    plant_carbon["sourceLoading_cp"] = 0.10
    params["category"]["leaf-carbon"].update({
        "baselineAssimilationToStarchFraction": 0.125,
        "solubleCarbonFloorFractionStructural": 0.02,
        "solubleCarbonTargetFractionStructural": 0.08,
        "starchCarbonFloorFractionStructural": 0.0,
        "maximumStarchMobilizationRatePerHour": 0.10,
        "overflowStarchSynthesisRatePerHour": 0.10,
        "solubleCarbonExportRatePerHour": 1.0,
        "maximumSolubleCarbonLoadingRatePerStructuralC": loading_cap_rate,
    })
    params["category"]["gasExchange"].update({
        "solubleFeedbackReferenceFractionStructural": 0.08,
        "solubleFeedbackHalfSaturation": 0.05,
        "solubleFeedbackHillExponent": 2.0,
        "solubleFeedbackWeight": 0.0,
    })
    initial = load_json(SCENARIOS / "initial.conditions.singleLeaf.json")
    initial["name"] = initial_name[:-5]
    initial["category"]["organ_age"]["PLANT_AGE_TD_AFTER_BUDBURST"] = 50
    initial["category"]["leaf"]["initialStarchFractionOfLeafNSC"] = 0.50
    initial["category"]["leaf"]["matureLeafTwoPoolInitialization"] = "fixedFraction"
    return suffix, options_name, params_name, initial_name, climate_name, options, params, initial


def finite(value):
    number = float(value)
    if not math.isfinite(number):
        raise AssertionError("non-finite diagnostic value: %r" % value)
    return number


def read_diagnostics(output_dir):
    path = output_dir / "diagnostics" / "leafExpansion_debug.csv"
    if not path.is_file():
        raise AssertionError("missing leaf diagnostic: %s" % path)
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        raise AssertionError("empty leaf diagnostic: %s" % path)
    return rows


def dawn_value(rows, key):
    """Return the last true-night value before the configured photoperiod."""
    for index, row in enumerate(rows):
        if row["isPhotoperiodLight"].lower() == "true":
            selected = rows[max(0, index - 1)]
            return finite(selected[key])
    return finite(rows[0][key])


def dusk_value(rows, key):
    """Return the last value recorded during the configured photoperiod."""
    selected = rows[-1]
    for row in rows:
        if row["isPhotoperiodLight"].lower() == "true":
            selected = row
    return finite(selected[key])


def summarise(treatment, rows):
    by_day = defaultdict(list)
    for row in rows:
        by_day[int(row["dayOfYear"])].append(row)
    summary = []
    for day in sorted(by_day):
        day_rows = by_day[day]
        summary.append({
            "treatment": treatment,
            "day": day,
            "dawnSolubleMgC": dawn_value(day_rows, "leafSolubleCarbonMgC"),
            "dawnStarchMgC": dawn_value(day_rows, "leafStarchCarbonMgC"),
            "duskSolubleMgC": dusk_value(day_rows, "leafSolubleCarbonMgC"),
            "duskStarchMgC": dusk_value(day_rows, "leafStarchCarbonMgC"),
            "dailyAssimilationMgC": sum(finite(row["carbonAssimilation"]) for row in day_rows),
            "dailyPhloemLoadingMgC": sum(finite(row["leafActualLoadingMgC"]) for row in day_rows),
            "dailyBaselineStarchSynthesisMgC": sum(finite(row["leafBaselineStarchSynthesisMgC"]) for row in day_rows),
            "dailyOverflowStarchSynthesisMgC": sum(finite(row["leafOverflowStarchSynthesisMgC"]) for row in day_rows),
            "dailyStarchDegradationMgC": sum(finite(row["leafStarchDegradationMgC"]) for row in day_rows),
            "dailyMaintenanceDemandMgC": sum(finite(row["leafMaintenanceDemandMgC"]) for row in day_rows),
            "dailyMaintenanceFromSolubleMgC": sum(finite(row["leafMaintenanceFromSolubleMgC"]) for row in day_rows),
            "dailyMaintenanceFromStarchMgC": sum(finite(row["leafMaintenanceFromStarchMgC"]) for row in day_rows),
            "dailyMaintenanceFromPhloemMgC": sum(finite(row["leafMaintenanceFromPhloemMgC"]) for row in day_rows),
            "maxAbsClosureResidualMgC": max(abs(finite(row["leafCarbonClosureResidualMgC"])) for row in day_rows),
        })
    return summary


def validate(rows_by_cp, summary):
    totals = {}
    for cp, rows in rows_by_cp.items():
        for index, row in enumerate(rows):
            if finite(row["leafSolubleCarbonMgC"]) < -1.0e-8:
                raise AssertionError("negative soluble pool at Cp=%s" % cp)
            if finite(row["leafStarchCarbonMgC"]) < -1.0e-8:
                raise AssertionError("negative starch pool at Cp=%s" % cp)
            imposed = finite(row["imposedPhloemSugar"])
            # The first row is the pre-evaluation initial state.
            if index > 0 and abs(imposed - cp) > 1.0e-9:
                raise AssertionError("imposed Cp mismatch: %s != %s" % (imposed, cp))
            if int(row["leafCarbonCommitCount"]) > int(row["step"]):
                raise AssertionError("more than one pool commit per model step")
            if abs(finite(row["leafMaintenanceFromPhloemMgC"])) > 1.0e-10:
                raise AssertionError("imposed Cp funded leaf maintenance at Cp=%s" % cp)
            if finite(row["leafStarchCarbonMgC"]) > 0.0:
                finite(row["leafStarchCarbonMgCPerGDM"])
            finite(row["leafSolubleCarbonMgCPerGDM"])
        cp_summary = [row for row in summary if row["treatment"] == cp]
        totals[cp] = {
            "loading": sum(row["dailyPhloemLoadingMgC"] for row in cp_summary),
            "degradation": sum(row["dailyStarchDegradationMgC"] for row in cp_summary),
            "overflow": sum(row["dailyOverflowStarchSynthesisMgC"] for row in cp_summary),
            "dawn_starch": cp_summary[-1]["dawnStarchMgC"],
            "dawn_soluble": cp_summary[-1]["dawnSolubleMgC"],
            "maintenance_phloem": sum(row["dailyMaintenanceFromPhloemMgC"] for row in cp_summary),
            "closure": max(row["maxAbsClosureResidualMgC"] for row in cp_summary),
        }
    if not totals[0.05]["loading"] > totals[0.10]["loading"] > totals[0.20]["loading"]:
        raise AssertionError("phloem loading treatment order failed: %r" % totals)
    if not totals[0.05]["dawn_starch"] < totals[0.10]["dawn_starch"] < totals[0.20]["dawn_starch"]:
        raise AssertionError("dawn starch treatment order failed: %r" % totals)
    if (totals[0.10]["dawn_soluble"] + 1.0e-8 < totals[0.05]["dawn_soluble"]
            or totals[0.20]["dawn_soluble"] <= totals[0.10]["dawn_soluble"]):
        raise AssertionError("dawn soluble treatment order failed: %r" % totals)
    if not totals[0.05]["degradation"] > totals[0.20]["degradation"]:
        raise AssertionError("starch degradation treatment order failed: %r" % totals)
    if max(value["closure"] for value in totals.values()) > 1.0e-7:
        raise AssertionError("carbon closure tolerance failed: %r" % totals)
    return totals


def write_summary(rows):
    path = ARTIFACTS / "single_leaf_carbon_daily_summary.csv"
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    return path


def write_plot(rows_by_cp):
    """Write a compact mechanism diagnostic when matplotlib is available."""
    os.environ.setdefault("MPLCONFIGDIR", str(ARTIFACTS / ".mplconfig"))
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        return None
    styles = {0.05: "#1f77b4", 0.10: "#ff7f0e", 0.20: "#d62728"}
    figure, axes = plt.subplots(3, 2, figsize=(11, 10), sharex=True)
    axes = axes.ravel()
    for cp in TREATMENTS:
        rows = rows_by_cp[cp]
        time_days = [index / 24.0 for index in range(len(rows))]
        color = styles[cp]
        label = "Cp=%.2f" % cp
        axes[0].plot(time_days, [cp] * len(rows), color=color, label=label)
        axes[1].plot(time_days, [finite(row["leafSolubleCarbonMgC"]) for row in rows], color=color)
        axes[2].plot(time_days, [finite(row["leafStarchCarbonMgC"]) for row in rows], color=color)
        axes[3].plot(time_days, [finite(row["leafActualLoadingMgC"]) for row in rows], color=color)
        synthesis = [
            finite(row["leafBaselineStarchSynthesisMgC"])
            + finite(row["leafOverflowStarchSynthesisMgC"])
            for row in rows
        ]
        axes[4].plot(time_days, synthesis, color=color, linestyle="-")
        axes[4].plot(
            time_days,
            [-finite(row["leafStarchDegradationMgC"]) for row in rows],
            color=color,
            linestyle="--",
        )
        axes[5].plot(time_days, [finite(row["carbonAssimilation"]) for row in rows], color=color)
    labels = (
        "(a) imposed phloem sugar (g/g)",
        "(b) soluble carbon (mg C)",
        "(c) starch carbon (mg C)",
        "(d) phloem loading (mg C/step)",
        "(e) starch synthesis (+) / degradation (-), mg C",
        "(f) assimilation (mg C/step)",
    )
    for axis, label in zip(axes, labels):
        axis.set_ylabel(label)
        axis.grid(alpha=0.25)
    axes[0].legend(frameon=False, ncol=3)
    axes[4].set_xlabel("time (days)")
    axes[5].set_xlabel("time (days)")
    figure.tight_layout()
    path = ARTIFACTS / "single_leaf_carbon_diagnostic.png"
    figure.savefig(path, dpi=150)
    plt.close(figure)
    return path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--keep-configs", action="store_true")
    args = parser.parse_args()
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    rows_by_cp = {}
    try:
        shared_written = False
        for cp in TREATMENTS:
            values = generated_inputs(cp)
            suffix, options_name, params_name, initial_name, climate_name = values[:5]
            options, params, initial = values[5:]
            options_path = SCENARIOS / options_name
            write_json(options_path, options)
            generated.append(options_path)
            if not shared_written:
                params_path = SCENARIOS / params_name
                initial_path = SCENARIOS / initial_name
                climate_path = INPUT / climate_name
                write_json(params_path, params)
                write_json(initial_path, initial)
                generated.extend([params_path, initial_path, climate_path])
                shared_written = True
            # The normal run snapshots may relocate transient climate inputs;
            # restore the controlled fixture before every treatment launch.
            write_climate(INPUT / climate_name)
            log_path = ARTIFACTS / ("cp%s.log" % suffix)
            command = [
                "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
                str(STEPS), options_name,
            ]
            with log_path.open("w", encoding="utf-8") as log:
                completed = subprocess.run(
                    command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                    timeout=300,
                )
            if completed.returncode != 0:
                raise RuntimeError("Cp=%s run failed with exit %d; see %s" % (cp, completed.returncode, log_path))
            log_text = log_path.read_text(encoding="utf-8", errors="replace")
            if "Unexpected Exception" in log_text or "Exception in run()" in log_text:
                raise RuntimeError("Cp=%s run reported a GroIMP exception; see %s" % (cp, log_path))
            output_dir = ROOT / "Model_output" / ("singleLeafCarbon_cp%s" % suffix)
            rows_by_cp[cp] = read_diagnostics(output_dir)
        summary = []
        for cp in TREATMENTS:
            summary.extend(summarise(cp, rows_by_cp[cp]))
        summary_path = write_summary(summary)
        totals = validate(rows_by_cp, summary)
        plot_path = write_plot(rows_by_cp)
        print("PASS: deterministic imposed-phloem single-leaf experiment")
        print("summary=%s" % summary_path)
        if plot_path is not None:
            print("figure=%s" % plot_path)
        for cp in TREATMENTS:
            print("Cp=%.2f %s" % (cp, totals[cp]))
        return 0
    finally:
        if not args.keep_configs:
            for path in generated:
                if path.is_file():
                    path.unlink()


if __name__ == "__main__":
    sys.exit(main())
