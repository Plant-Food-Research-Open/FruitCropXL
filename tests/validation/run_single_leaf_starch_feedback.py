#!/usr/bin/env python3
"""Second-stage headless test of the optional slow starch feedback."""

import importlib.util
import math
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RUNNER_PATH = ROOT / "tests" / "validation" / "run_single_leaf_carbon.py"
SPEC = importlib.util.spec_from_file_location("single_leaf_carbon_runner", RUNNER_PATH)
runner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runner)


def main():
    runner.ARTIFACTS.mkdir(parents=True, exist_ok=True)
    generated = []
    rows_by_cp = {}
    try:
        shared_written = False
        cases = (
            ("starchLow", "starchAcclimation", 0.05),
            ("starchHigh", "starchAcclimation", 0.20),
            ("combinedHigh", "carbohydrateExcessAcclimation", 0.20),
        )
        for label, mode, cp in cases:
            values = runner.generated_inputs(cp)
            suffix, old_name, params_name, initial_name, climate_name = values[:5]
            options, params, initial = values[5:]
            options_name = old_name.replace(
                "singleLeafCarbon", "singleLeafFeedback.%s" % label
            )
            options["name"] = options_name[:-5]
            options["category"]["module_configuration"][
                "leafPhotosynthesisCarbonFeedback"
            ] = mode
            options_path = runner.SCENARIOS / options_name
            runner.write_json(options_path, options)
            generated.append(options_path)
            if not shared_written:
                params_path = runner.SCENARIOS / params_name
                initial_path = runner.SCENARIOS / initial_name
                climate_path = runner.INPUT / climate_name
                gas_exchange = params["category"]["gasExchange"]
                gas_exchange.update({
                    "starchFeedbackReferenceFractionStructural": 0.24,
                    "starchFeedbackHalfSaturation": 0.05,
                    "solubleFeedbackReferenceFractionStructural": 0.08,
                    "solubleFeedbackHalfSaturation": 0.20,
                    "solubleFeedbackHillExponent": 2.0,
                    "solubleFeedbackWeight": 0.8,
                })
                runner.write_json(params_path, params)
                runner.write_json(initial_path, initial)
                runner.write_climate(climate_path)
                generated.extend([params_path, initial_path, climate_path])
                shared_written = True
            log_path = runner.ARTIFACTS / ("feedback_%s_cp%s.log" % (label, suffix))
            command = [
                "bash", "tests/smoke_test/unitTest.sh", "Xrun", "default",
                str(runner.STEPS), options_name,
            ]
            with log_path.open("w", encoding="utf-8") as log:
                completed = subprocess.run(
                    command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                    timeout=300,
                )
            if completed.returncode != 0:
                raise RuntimeError(
                    "feedback %s Cp=%s failed with exit %d; see %s"
                    % (mode, cp, completed.returncode, log_path)
                )
            output_name = "singleLeafFeedback_%s_cp%s" % (label, suffix)
            rows_by_cp[label] = runner.read_diagnostics(
                ROOT / "Model_output" / output_name
            )

        final_states = {}
        late_assimilation = {}
        target_ranges = {}
        final_soluble = {}
        for label, rows in rows_by_cp.items():
            states = [runner.finite(row["leafStarchFeedbackState"]) for row in rows]
            targets = [runner.finite(row["leafStarchFeedbackTarget"]) for row in rows]
            if any(value < -1.0e-12 or value > 1.0 for value in states):
                raise AssertionError("feedback state outside zero through one")
            if label != "starchLow" and states[-1] <= states[0]:
                raise AssertionError("feedback did not rise for %s" % label)
            final_states[label] = states[-1]
            late_assimilation[label] = sum(
                runner.finite(row["carbonAssimilation"]) for row in rows[-48:]
            )
            if label != "starchLow" and max(targets) <= 0.0:
                raise AssertionError("feedback target never activated for %s" % label)
            target_ranges[label] = max(targets[-48:]) - min(targets[-48:])
            final_soluble[label] = runner.finite(rows[-1]["leafSolubleCarbonMgC"])
        if final_states["starchHigh"] <= final_states["starchLow"]:
            raise AssertionError("high-Cp feedback did not exceed low-Cp feedback")
        if late_assimilation["starchHigh"] >= late_assimilation["starchLow"]:
            raise AssertionError("late high-Cp assimilation was not inhibited")
        if final_states["combinedHigh"] <= final_states["starchHigh"]:
            raise AssertionError("combined feedback did not respond beyond starch-only")
        if final_soluble["combinedHigh"] <= 0.0:
            raise AssertionError("combined high-Cp case did not retain soluble carbon")
        print("PASS: starch-only and combined carbohydrate acclimation integration")
        print("finalFeedbackState=%r" % final_states)
        print("last48hAssimilationMgC=%r" % late_assimilation)
        print("last48hTargetRange=%r" % target_ranges)
        print("finalSolubleMgC=%r" % final_soluble)
        return 0
    finally:
        for path in generated:
            if path.is_file():
                path.unlink()


if __name__ == "__main__":
    sys.exit(main())
