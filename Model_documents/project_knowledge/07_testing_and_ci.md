# Testing and CI workflow (current expected practice)

## Test-suite ownership

- `tests/validation/` contains scenario fixtures and shared GroIMP validation
  runners.
- `tests/smoke_test/` contains the portable direct-Java GroIMP smoke runner.
- `tests/diagnosis/` contains focused static and runtime diagnostic helpers.
- `tests/gsz_test/` contains packaged-project structure, reproducibility,
  timeout, and functional checks.
- `tests/cellml/` contains the external dependency, standalone backend, and
  deterministic single-fruit CellML integration checks.
- Other feature-owned suites remain in their named top-level `tests/`
  directories. See `tests/README.md` before adding another validation script.

## Cloud/hosted Codex smoke test (required)

- Run only: `bash tests/smoke_test/unitTest.sh`
- This is the portable baseline check for this environment.

## Local acceptance workflow (non-cloud)

- Preferred acceptance command: `bash tests/validation/run_multiple_scenarios.sh default`
- Acceptance criterion: run succeeds and updates `Model_output/default/`.

## Key scripts and roles

- `tests/smoke_test/unitTest.sh`: direct Java + GroIMP core.jar portable test runner.
- `tests/validation/run_groimp_tests.sh`: Apptainer-based launcher.
- `tests/validation/run_multiple_scenarios.sh`: parallelized multi-scenario wrapper + per-scenario logs.
- `tests/diagnosis/grep_compile_errors.sh`: semantic compile error scan utility.
- `tests/gsz_test/validate_gsz_structure.sh`: packaged-project structure and source/archive consistency check.
- `tests/cellml/test_cellml_dependency.sh`: model-JAR inventory, checksum, Java class version, and Commons Math provider check.
- `tests/cellml/test_cellml_backend.sh`: plain-Java model subclass, backend, state, rollback, and conversion tests.
- `tests/cellml/test_cellml_single_fruit.sh`: short GroIMP graph-organ integration and output regression.

## Pass/fail conventions

- `set -euo pipefail` in runners means non-zero exit indicates failure.
- Multi-scenario runner records failed scenarios and exits non-zero if any fail.
- Shared scenario logs are expected in `tests/validation/<scenario>.log`;
  feature tests document any separate logs they create.

## CI conventions relevant locally

- Keep local validation aligned with in-repo scripts rather than ad hoc commands.
- For source edits tested via `Scripts/Scripts.gsz`, run source validation first, then rebuild only with `bash bash_scripts/zip_groimp.sh` and validate with `bash tests/gsz_test/validate_gsz_structure.sh`; avoid archive edits in hosted tasks unless explicitly requested.
- Archive packaging uses working-tree model sources but committed-`HEAD` copies of GroIMP-managed `Scripts/project.gs`, `Scripts/graph*.xml`, `Scripts/META-INF/MANIFEST.MF`, and `Scripts/workbench.options`; local and staged-but-uncommitted GroIMP metadata is ignored unless explicit worktree mode is selected.
- CI checks exact canonical archive contents and two-build byte reproducibility, but does not hard-code an archive SHA-256 or individual GroIMP-generated node IDs.
