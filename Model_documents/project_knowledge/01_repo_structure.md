# Repository structure map (practical)

## Top-level execution-critical folders
- `Scripts/`: GroIMP project and model source modules.
- `Model_scenarios/`: scenario JSONs and templates.
- `Model_input/`: climate and other runtime inputs.
- `tests/`: shared validation plus feature-owned suites such as `tests/cellml/`.
- `bash_scripts/`: headless helpers, zip/run utilities.
- `Model_output/`: generated outputs (including `default/`).
- `Model_documents/`: in-repo documentation, call graphs, guides, references.

## Core code locations
- Main loop and wiring: `Scripts/main/` (`main.rgg`, `updatesBase.rgg`, `developBase.rgg`, `outputTables.rgg`).
- Runtime config loading: `Scripts/config/` (`globalParameters.rgg`, `modelOptions.rgg`, `plantParameters.rgg`, `initialConditions.rgg`).
- Environment/soil: `Scripts/environment/`.
- Physiology: `Scripts/physioFunctions/`.
- Organ definitions: `Scripts/organs/`.
- Module variants: `Scripts/alterModules/`.
- Utilities + Java helpers: `Scripts/utils/`, `Scripts/dataModels/`.

## Scenario/config/documentation anchors
- Scenario templates: `Model_scenarios/_templates/`.
- Config user guides: `Model_documents/config-execution/`.
- Call graph and execution docs: `Model_documents/Call Graphs/`.
- GroIMP/XL platform docs and notes: `Model_documents/softdoc/`.

## Output + validation anchors
- Test ownership map: `tests/README.md`; scenario validation, portable smoke,
  diagnostics, and packaged-project checks are separated under
  `tests/validation/`, `tests/smoke_test/`, `tests/diagnosis/`, and
  `tests/gsz_test/`.
- CI workflow definitions: `.github/workflows/`.
- Default output location: `Model_output/default/`.
