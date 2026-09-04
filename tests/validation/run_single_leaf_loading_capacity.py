#!/usr/bin/env python3
"""Compare disabled and test-only leaf loading-capacity treatments."""

import importlib.util
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BASE_PATH = ROOT / "tests" / "validation" / "run_single_leaf_carbon.py"
SPEC = importlib.util.spec_from_file_location("leaf_carbon_base", BASE_PATH)
base = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(base)

TEST_ONLY_CAP_RATE = 0.01  # mg C load mg-1 structural C h-1 == h-1


def percentile(values, probability):
    ordered = sorted(values)
    if not ordered:
        return 0.0
    index = int(round(probability * (len(ordered) - 1)))
    return ordered[index]


def run_case(cp, cap_rate, generated):
    label = "off" if cap_rate <= 0.0 else "testCap001"
    values = base.generated_inputs(cp, cap_rate)
    suffix = values[0]
    options, params, initial = values[5:]
    options_name = "model.options.singleLeafLoading.%s.cp%s.json" % (label, suffix)
    params_name = "plant.parameters.singleLeafLoading.%s.cp%s.json" % (label, suffix)
    initial_name = "initial.conditions.singleLeafLoading.%s.cp%s.json" % (label, suffix)
    climate_name = "Metdata_singleLeafLoading.%s.cp%s.csv" % (label, suffix)
    options["name"] = options_name[:-5]
    module = options["category"]["module_configuration"]
    module["FILE_NAME_PLANT_PARAMETERS"] = params_name
    module["FILE_NAME_INITIAL_CONDITIONS"] = initial_name
    options["category"]["environment_climate"]["climate_file"] = climate_name
    params["name"] = params_name[:-5]
    initial["name"] = initial_name[:-5]
    paths = (
        base.SCENARIOS / options_name,
        base.SCENARIOS / params_name,
        base.SCENARIOS / initial_name,
        base.INPUT / climate_name,
    )
    base.write_json(paths[0], options)
    base.write_json(paths[1], params)
    base.write_json(paths[2], initial)
    base.write_climate(paths[3])
    generated.extend(paths)
    log_path = base.ARTIFACTS / ("loading_%s_cp%s.log" % (label, suffix))
    command = [
        "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
        str(base.STEPS), options_name,
    ]
    with log_path.open("w", encoding="utf-8") as log:
        completed = subprocess.run(
            command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, timeout=300,
        )
    if completed.returncode != 0:
        raise RuntimeError("%s Cp=%s failed; see %s" % (label, cp, log_path))
    rows = base.read_diagnostics(
        ROOT / "Model_output" / ("singleLeafLoading_%s_cp%s" % (label, suffix))
    )
    mature = [row for row in rows if int(row["leafCarbonCommitCount"]) > 0]
    for row in mature:
        raw = base.finite(row["leafRawPotentialLoadingMgC"])
        potential = base.finite(row["leafPotentialLoadingMgC"])
        factor = base.finite(row["leafSourceLoadingFactor"])
        actual = base.finite(row["leafActualLoadingMgC"])
        # `loading` is retained as a legacy float while the diagnostics are doubles.
        if abs(actual - potential * factor) > 1.0e-6:
            raise AssertionError("loading no longer equals potential * sourceLoading(Cp)")
        if cap_rate <= 0.0 and abs(raw - potential) > 1.0e-10:
            raise AssertionError("disabled ceiling changed raw potential loading")
        if abs(base.finite(row["leafCarbonClosureResidualMgC"])) > 1.0e-7:
            raise AssertionError("carbon closure failed")
    rates = [base.finite(row["leafPotentialLoadingPerStructuralCPerHour"])
             for row in mature]
    limited = sum(row["leafLoadingCapacityLimited"].lower() == "true" for row in mature)
    return {
        "rows": len(mature),
        "limited": limited,
        "rateP50": percentile(rates, 0.50),
        "rateP95": percentile(rates, 0.95),
        "rateMax": max(rates),
        "totalRaw": sum(base.finite(row["leafRawPotentialLoadingMgC"]) for row in mature),
        "totalPotential": sum(base.finite(row["leafPotentialLoadingMgC"]) for row in mature),
        "totalActual": sum(base.finite(row["leafActualLoadingMgC"]) for row in mature),
        "meanFactor": sum(base.finite(row["leafSourceLoadingFactor"]) for row in mature)
        / max(1, len(mature)),
        "finalSoluble": base.finite(mature[-1]["leafSolubleCarbonMgC"]),
        "finalStarch": base.finite(mature[-1]["leafStarchCarbonMgC"]),
        "overflow": sum(base.finite(row["leafOverflowStarchSynthesisMgC"]) for row in mature),
        "log": str(log_path),
    }


def main():
    base.ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    results = {}
    try:
        for cap_rate in (0.0, TEST_ONLY_CAP_RATE):
            for cp in base.TREATMENTS:
                results[(cap_rate, cp)] = run_case(cp, cap_rate, generated)
        for cap_rate in (0.0, TEST_ONLY_CAP_RATE):
            factors = [results[(cap_rate, cp)]["meanFactor"] for cp in base.TREATMENTS]
            if not factors[0] > factors[1] > factors[2]:
                raise AssertionError("sourceLoading(Cp) suppression was not preserved")
        if not any(results[(TEST_ONLY_CAP_RATE, cp)]["limited"] > 0
                   for cp in base.TREATMENTS):
            raise AssertionError("test-only loading ceiling was never active")
        print("PASS: optional size-scaled loading capacity")
        print("testOnlyCapRateH-1=%s" % TEST_ONLY_CAP_RATE)
        for key in sorted(results):
            print("cap=%s Cp=%s %r" % (key[0], key[1], results[key]))
        return 0
    finally:
        for path in generated:
            if path.is_file():
                path.unlink()


if __name__ == "__main__":
    sys.exit(main())
