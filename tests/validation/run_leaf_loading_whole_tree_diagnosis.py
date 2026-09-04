#!/usr/bin/env python3
"""Reduced FOPS crop-load diagnosis for uncapped mature-leaf loading."""

import csv
import json
import math
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCENARIOS = ROOT / "Model_scenarios"
SOURCE = SCENARIOS / "FOPS_CropLoad"
ARTIFACTS = ROOT / "tests" / "validation" / "leaf_carbon_single_leaf"
STEPS = 48
CASES = (
    ("noFruit", "model.options.-9ca2bf8b-c639-48c1-a98f-bbc84bb43b73.json", 0, 0.0),
    ("highCrop", "model.options.-697271f9-f862-464c-9f8c-cf8d3f6f3d60.json", 600, 0.0),
    # Mechanism test only; this is not an apple parameter recommendation.
    ("highCropCapTest", "model.options.-697271f9-f862-464c-9f8c-cf8d3f6f3d60.json", 600, 0.02),
)


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def percentile(values, p):
    ordered = sorted(values)
    if not ordered:
        return 0.0
    return ordered[int(round(p * (len(ordered) - 1)))]


def finite(row, key):
    value = float(row[key])
    if not math.isfinite(value):
        raise AssertionError("non-finite %s" % key)
    return value


def distribution(rows, key):
    values = [finite(row, key) for row in rows]
    return {
        "p05": percentile(values, 0.05),
        "p50": percentile(values, 0.50),
        "p95": percentile(values, 0.95),
        "max": max(values),
    }


def transport_closure(output_name):
    path = (ROOT / "Model_output" / output_name / "diagnostics"
            / "debug_ct_mass_balance.csv")
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    converged = [row for row in rows if row["ctConverged"].lower() == "true"]
    fallback = [
        row for row in rows
        if row["ctSolverFallbackUsed"].lower() == "true"
    ]
    if len(converged) + len(fallback) != len(rows):
        raise AssertionError("unclassified carbon-transport state in %s" % path)
    if any(row["foldCoverageComplete"].lower() != "true"
           or row["unfoldCoverageComplete"].lower() != "true"
           for row in converged):
        raise AssertionError("incomplete converged CT coverage in %s" % path)
    relative = [abs(finite(row, "relativeFluxResidual")) for row in converged]
    if relative and max(relative) > 1.0e-3:
        raise AssertionError("converged whole-plant CT closure exceeded tolerance")
    return {
        "ctConvergedRows": len(converged),
        "ctFallbackRows": len(fallback),
        "ctMaxAbsNetFluxResidual": max(
            [abs(finite(row, "netFluxResidual")) for row in converged],
            default=0.0,
        ),
        "ctMaxRelativeFluxResidual": max(relative, default=0.0),
        "ctMaxAbsFoldClosureResidual": max(
            [abs(finite(row, "closureResidual")) for row in converged],
            default=0.0,
        ),
    }


def cp_strata(rows):
    # Compare source-active observations. Including night/empty-source rows makes
    # the low-Cp median raw loading zero and creates a spurious compensation flag.
    active = [
        row for row in rows
        if finite(row, "leafRawPotentialLoadingMgC") > 1.0e-9
    ]
    ordered = sorted(active, key=lambda row: finite(row, "sugarConcentration_phloem"))
    if not ordered:
        raise AssertionError("no source-active mature-leaf rows")
    n = max(1, len(ordered) // 4)
    result = {}
    for label, selected in (("lowCp", ordered[:n]), ("highCp", ordered[-n:])):
        result[label] = {
            "Cp": distribution(selected, "sugarConcentration_phloem")["p50"],
            "solubleToStructural": distribution(selected, "leafSolubleCToStructuralC")["p50"],
            "rawPotentialMgC": distribution(selected, "leafRawPotentialLoadingMgC")["p50"],
            "sourceFactor": distribution(selected, "leafSourceLoadingFactor")["p50"],
            "actualLoadingMgC": distribution(selected, "leafActualLoadingMgC")["p50"],
            "rawRateH-1": distribution(selected, "leafPotentialLoadingPerStructuralCPerHour")["p50"],
        }
    low = result["lowCp"]
    high = result["highCp"]
    result["compensationFlag"] = (
        high["sourceFactor"] < 0.8 * low["sourceFactor"]
        and high["actualLoadingMgC"] >= low["actualLoadingMgC"]
    )
    return result


def main():
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    summaries = []
    try:
        for label, source_name, target_fruit, loading_cap in CASES:
            options = load(SOURCE / source_name)
            options_name = "model.options.leafLoadingFOPS.%s.json" % label
            params_name = "plant.parameters.leafLoadingFOPS.%s.json" % label
            initial_name = "initial.conditions.leafLoadingFOPS.%s.json" % label
            options["name"] = options_name[:-5]
            module = options["category"]["module_configuration"]
            module["FILE_NAME_PLANT_PARAMETERS"] = params_name
            module["FILE_NAME_INITIAL_CONDITIONS"] = initial_name
            module["leafCarbonModel"] = "solubleStarch"
            module["leafPhotosynthesisCarbonFeedback"] = "none"
            output = options["category"]["output_controls"]
            output["outputLeafGrowthDiagnostics"] = True
            output["debugLeafExpansionSampleEvery"] = 1
            params = load(SCENARIOS / "plant.parameters.RG-empirical.json")
            params["name"] = params_name[:-5]
            params["category"]["leaf-carbon"].update({
                "baselineAssimilationToStarchFraction": 0.125,
                "solubleCarbonFloorFractionStructural": 0.02,
                "solubleCarbonTargetFractionStructural": 0.08,
                "starchCarbonFloorFractionStructural": 0.0,
                "maximumStarchMobilizationRatePerHour": 0.10,
                "overflowStarchSynthesisRatePerHour": 0.10,
                "solubleCarbonExportRatePerHour": 1.0,
                "maximumSolubleCarbonLoadingRatePerStructuralC": loading_cap,
            })
            initial = load(SCENARIOS / "initial.conditions.FOPS-D34.json")
            initial["name"] = initial_name[:-5]
            initial["category"]["leaf"]["initialStarchFractionOfLeafNSC"] = 0.5
            initial["category"]["leaf"]["matureLeafTwoPoolInitialization"] = "fixedFraction"
            paths = (SCENARIOS / options_name, SCENARIOS / params_name, SCENARIOS / initial_name)
            write(paths[0], options)
            write(paths[1], params)
            write(paths[2], initial)
            generated.extend(paths)
            log_path = ARTIFACTS / ("whole_tree_loading_%s.log" % label)
            command = [
                "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
                str(STEPS), options_name,
            ]
            with log_path.open("w", encoding="utf-8") as log:
                completed = subprocess.run(
                    command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, timeout=300,
                )
            if completed.returncode != 0:
                raise RuntimeError("%s failed; see %s" % (label, log_path))
            diagnostic = (ROOT / "Model_output" / ("leafLoadingFOPS_%s" % label)
                          / "diagnostics" / "leafExpansion_debug.csv")
            with diagnostic.open(newline="", encoding="utf-8") as handle:
                rows = [row for row in csv.DictReader(handle)
                        if int(row["leafCarbonCommitCount"]) > 0]
            if not rows:
                raise AssertionError("no mature leaves in %s" % label)
            limited_rows = sum(
                row["leafLoadingCapacityLimited"].lower() == "true"
                for row in rows
            )
            if loading_cap <= 0.0 and limited_rows:
                raise AssertionError("disabled loading ceiling became active")
            if loading_cap > 0.0 and not limited_rows:
                raise AssertionError("test loading ceiling was never exercised")
            closure = max(abs(finite(row, "leafCarbonClosureResidualMgC")) for row in rows)
            if closure > 1.0e-7:
                raise AssertionError("leaf closure failed in %s" % label)
            strata = cp_strata(rows)
            ct_closure = transport_closure("leafLoadingFOPS_%s" % label)
            summary = {
                "case": label,
                "targetFruitPerTree": target_fruit,
                "testLoadingCapH-1": loading_cap,
                "matureRows": len(rows),
                "sourceActiveRows": sum(
                    finite(row, "leafRawPotentialLoadingMgC") > 1.0e-9
                    for row in rows
                ),
                "CpP05": distribution(rows, "sugarConcentration_phloem")["p05"],
                "CpP50": distribution(rows, "sugarConcentration_phloem")["p50"],
                "CpP95": distribution(rows, "sugarConcentration_phloem")["p95"],
                "rawRateP50H-1": distribution(rows, "leafPotentialLoadingPerStructuralCPerHour")["p50"],
                "rawRateP95H-1": distribution(rows, "leafPotentialLoadingPerStructuralCPerHour")["p95"],
                "rawRateMaxH-1": distribution(rows, "leafPotentialLoadingPerStructuralCPerHour")["max"],
                "lowCpSourceFactor": strata["lowCp"]["sourceFactor"],
                "highCpSourceFactor": strata["highCp"]["sourceFactor"],
                "lowCpRawMgC": strata["lowCp"]["rawPotentialMgC"],
                "highCpRawMgC": strata["highCp"]["rawPotentialMgC"],
                "lowCpActualMgC": strata["lowCp"]["actualLoadingMgC"],
                "highCpActualMgC": strata["highCp"]["actualLoadingMgC"],
                "compensationFlag": strata["compensationFlag"],
                "capacityLimitedRows": limited_rows,
                "capacityLimitedFraction": limited_rows / len(rows),
                "maxAbsClosureMgC": closure,
                "log": str(log_path),
            }
            summary.update(ct_closure)
            summaries.append(summary)
            print("%s %r" % (label, summary))
        summary_path = ARTIFACTS / "whole_tree_loading_capacity_diagnosis.csv"
        with summary_path.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(summaries[0]))
            writer.writeheader()
            writer.writerows(summaries)
        print("PASS: reduced FOPS crop-load diagnosis and test-cap comparison")
        print("summary=%s" % summary_path)
        return 0
    finally:
        for path in generated:
            if path.is_file():
                path.unlink()


if __name__ == "__main__":
    sys.exit(main())
