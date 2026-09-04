#!/usr/bin/env python3
"""Run 24 h two-pool smoke tests through CTRAM and common-pool paths."""

import json
import math
from collections import defaultdict
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCENARIOS = ROOT / "Model_scenarios"
ARTIFACTS = ROOT / "tests" / "validation" / "leaf_carbon_single_leaf"
CASES = (
    ("appleCtram", "model.options.default.json", True),
    ("grapevineCommonPool", "model.options.Sauvignon.blanc.NZ.json", False),
)
PARAMETERS = {
    "baselineAssimilationToStarchFraction": 0.125,
    "solubleCarbonFloorFractionStructural": 0.02,
    "solubleCarbonTargetFractionStructural": 0.08,
    "starchCarbonFloorFractionStructural": 0.0,
    "maximumStarchMobilizationRatePerHour": 0.10,
    "overflowStarchSynthesisRatePerHour": 0.10,
    "solubleCarbonExportRatePerHour": 1.0,
    "maximumSolubleCarbonLoadingRatePerStructuralC": 0.0,
}


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def main():
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    try:
        for label, base_options_name, use_ctram in CASES:
            options = load(SCENARIOS / base_options_name)
            categories = options["category"]
            module = categories["module_configuration"]
            base_params_name = module["FILE_NAME_PLANT_PARAMETERS"]
            base_initial_name = module["FILE_NAME_INITIAL_CONDITIONS"]
            options_name = "model.options.leafCarbonWholePlant.%s.json" % label
            params_name = "plant.parameters.leafCarbonWholePlant.%s.json" % label
            initial_name = "initial.conditions.leafCarbonWholePlant.%s.json" % label
            options["name"] = options_name[:-5]
            module["FILE_NAME_PLANT_PARAMETERS"] = params_name
            module["FILE_NAME_INITIAL_CONDITIONS"] = initial_name
            module["leafCarbonModel"] = "solubleStarch"
            module["leafPhotosynthesisCarbonFeedback"] = "none"
            categories["model_functionality"]["useCTRAM"] = use_ctram
            output = categories["output_controls"]
            output["outputLeafGrowthDiagnostics"] = True
            output["debugLeafExpansionSampleEvery"] = 1

            params = load(SCENARIOS / base_params_name)
            params["name"] = params_name[:-5]
            params["category"]["leaf-carbon"].update(PARAMETERS)
            initial = load(SCENARIOS / base_initial_name)
            initial["name"] = initial_name[:-5]
            initial["category"]["leaf"]["initialStarchFractionOfLeafNSC"] = 0.50
            initial["category"]["leaf"]["matureLeafTwoPoolInitialization"] = "fixedFraction"

            paths = (
                SCENARIOS / options_name,
                SCENARIOS / params_name,
                SCENARIOS / initial_name,
            )
            write(paths[0], options)
            write(paths[1], params)
            write(paths[2], initial)
            generated.extend(paths)
            log_path = ARTIFACTS / ("whole_plant_%s.log" % label)
            command = [
                "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
                "24", options_name,
            ]
            with log_path.open("w", encoding="utf-8") as log:
                result = subprocess.run(
                    command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                    timeout=300,
                )
            log_text = log_path.read_text(encoding="utf-8", errors="replace")
            if (
                result.returncode != 0
                or "Unexpected Exception" in log_text
                or "Exception in run()" in log_text
            ):
                raise RuntimeError("%s failed; see %s" % (label, log_path))
            output_name = "leafCarbonWholePlant_%s" % label
            diagnostic = (
                ROOT / "Model_output" / output_name / "diagnostics"
                / "leafExpansion_debug.csv"
            )
            if not diagnostic.is_file():
                raise RuntimeError("missing diagnostic for %s" % label)
            import csv
            with diagnostic.open(newline="", encoding="utf-8") as handle:
                rows = list(csv.DictReader(handle))
            mature = [
                row for row in rows if int(row["leafCarbonCommitCount"]) > 0
            ]
            if not mature:
                raise RuntimeError("no mature two-pool leaf committed in %s" % label)
            for row in mature:
                values = [
                    float(row["leafSolubleCarbonMgC"]),
                    float(row["leafStarchCarbonMgC"]),
                    float(row["leafCarbonClosureResidualMgC"]),
                ]
                if not all(math.isfinite(value) for value in values):
                    raise RuntimeError("non-finite two-pool state in %s" % label)
                if values[0] < -1.0e-8 or values[1] < -1.0e-8:
                    raise RuntimeError("negative two-pool state in %s" % label)
                if abs(values[2]) > 1.0e-7:
                    raise RuntimeError("closure failure in %s" % label)
                if int(row["leafCarbonCommitCount"]) > int(row["step"]):
                    raise RuntimeError("double commit in %s" % label)
            by_leaf = defaultdict(list)
            for row in mature:
                by_leaf[row["leafId"]].append(
                    (int(row["step"]), int(row["leafCarbonCommitCount"]))
                )
            for leaf_id, values in by_leaf.items():
                values.sort()
                for previous, current in zip(values, values[1:]):
                    if (current[0] == previous[0] + 1
                            and current[1] != previous[1] + 1):
                        raise RuntimeError(
                            "commit count did not advance exactly once for leaf %s in %s"
                            % (leaf_id, label)
                        )
            print(
                "PASS: %s useCTRAM=%s matureRows=%d log=%s"
                % (label, use_ctram, len(mature), log_path)
            )
        return 0
    finally:
        for path in generated:
            if path.is_file():
                path.unlink()


if __name__ == "__main__":
    sys.exit(main())
