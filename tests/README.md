# FruitCropXL tests

Tests are grouped by the runtime or feature they own.

| Location | Scope | Main entry points |
| --- | --- | --- |
| `tests/validation/` | Scenario fixtures and GroIMP validation runners | `run_like_github_actions.sh`, `run_multiple_scenarios.sh` |
| `tests/smoke_test/` | Portable direct-Java GroIMP smoke testing | `unitTest.sh` |
| `tests/diagnosis/` | Focused static and runtime diagnostic helpers | `grep_compile_errors.sh`, targeted `check_*` scripts |
| `tests/gsz_test/` | Packaged-project structure, reproducibility, timeout, and functional checks | `validate_gsz_structure.sh`, `run_archive_test.sh` |
| `tests/cellml/` | External CellML JAR, plain-Java backend, and deterministic `CellmlFruit` graph integration | `test_cellml_dependency.sh`, `test_cellml_backend.sh`, `test_cellml_single_fruit.sh` |
| `tests/dhs_integration/` | Digital-horticultural-system coupling | See its local README |
| `tests/model_checklist/` | Model metadata/checklist tooling | See its local README |
| `tests/scenario_list_runner/` | Explicit scenario-list execution | See its local README |

Keep a test in `tests/validation/` when it validates a named model scenario or
provides the shared scenario-validation runtime. Put portable smoke tests,
diagnostic helpers, archive checks, and cohesive feature suites in their named
top-level directories.
Avoid duplicate canonical scripts with suffixes such as `.new`, `.updated`, or
`.bak`; update the maintained entry point and its documentation instead.

Repository-wide execution policy and reporting requirements remain in
`AGENTS.md`. Each test category has a local README with its maintained entry
points.
