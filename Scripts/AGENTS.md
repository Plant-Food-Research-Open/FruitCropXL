# Scripts — GroIMP Project Layout & Execution Rules

This folder contains the GroIMP project and most model source modules (RGG/Java assets plus images).

For portable baseline validation, prefer:
- `bash tests/smoke_test/unitTest.sh`
For local acceptance:
- `bash tests/validation/run_multiple_scenarios.sh default`

## Online vs local execution policy

### Hosted/online runs (portable smoke only)
- Assume apptainer/singularity and local OS tooling may be unavailable.
- Prefer:
  - `bash tests/smoke_test/unitTest.sh`
- Avoid long seasonal runs online unless explicitly required.

### Local machine runs (broader validation)
- Local acceptance test:
  - `bash tests/validation/run_multiple_scenarios.sh default`
- Acceptance rule for local `default`:
  - if it runs and updates `Model_output/default/`, it is OK
  - it does not need to pass all strict validation checks
- Extended tests using apptainer are local-only.

## Scripts folder structure (authoritative)

### Entry / wiring
- `project.gs` — project entrypoint
- `Scripts.gsz` — GroIMP project archive
- `graph.xml` — graph definition
- `main/` — main wiring + update/develop + outputs + charts
  - `main.rgg`, `developBase.rgg`, `updatesBase.rgg`, `outputTables.rgg`, `charts.rgg`

### Configuration and runtime bases
- `config/`
  - `globalParameters.rgg`, `plantParameters.rgg`, `modelOptions.rgg`, `initialConditions.rgg`
  - `initiationBase.rgg`, `simRunBase.rgg`

### Major modules
- `environment/` — `environment.rgg`, `soilBase.rgg`, `soil.rgg`
- `physioFunctions/` — phenology, photosynthesis/transpiration, carbon transport, etc.
- `management/` — pruning + planners + shoot positioning
- `organs/` — leaf/shoot/canopy + rootSystem + base/abstract organs
- `alterModules/` — pluggable variants: develop/updates/initiation/simRun + buds/fruit/Flowers

### Utilities / support code
- `utils/` — tasks, dataset, validation, server/socket, archReader, extraTools, etc.
- `dataModels/` — Java DTOs for outputs
- `images/` — PNG assets used by model/visualization

## Guardrails
- Do not rename/move `project.gs`, `Scripts.gsz`, `graph.xml`, or output table definitions unless explicitly requested.
- Keep diffs minimal and localized.
- When adding outputs, ensure units and naming are consistent with `main/outputTables.rgg`.
