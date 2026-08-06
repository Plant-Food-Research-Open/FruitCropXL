# Inputs, outputs, and configuration conventions

## Scenario/config file conventions
- Primary runtime config: `Model_scenarios/model.options.*.json` with `category` wrapper.
- Parameter/config companions:
  - `plant.parameters.*.json`
  - `initial.conditions.*.json`
  - soil parameter file
- Location rules:
  - scenario + parameter JSONs in `Model_scenarios/`
  - climate/support CSVs in `Model_input/`.

## Important runtime switches
- `module_configuration`: species, initiation, module complexity toggles, root biomass init policy.
- `model_functionality`: light/PT/carbon/development/management controls. `calcLightInterception` is the light master switch; `lightInterceptionMode` selects `cpu`, `gpu`, `empiricalRegression`, `surrogateModel`, or `directInput`.
- `output_controls`: table selection, stepwise output, organ-level outputs, snapshots, and explicit diagnostic-family switches.
- `simulation_time`: start/halt/harvest timing.

Light model/input filenames belong in `scenario_required_files`: `lightInterceptionModelFile`, `lightInterceptionFeatureManifestFile`, and `lightInterceptionInputFile`. Relative `lightInterceptionModelFile` names resolve from `Model_scenarios/`; the former `Model_input/` location is a deprecated fallback. The maintained Beer-Lambert example is `model.options.empiricalRegression.beerLambert.json` plus `light.interception.model.beer-lambert-lai-above.json`. Empirical and surrogate modes require versioned assets with explicit units, resolution, response, supported organ types and predictor contracts. In leaf gas-exchange test scenarios, `directInput` instead converts meteorological `globalRadiation` with environmental `fPAR` exactly once, without a separate light asset or ray tracing. Generic `directInput` remains file-backed through `lightInterceptionInputFile`. Repository `.pkl` files are Python-only and cannot be loaded by GroIMP. Strict mode is the default; allowed fallback requires an explicit `lightInterceptionFallbackMode` and is recorded in run provenance.

## Key outputs
- Stepwise and aggregate CSV tables written via `Scripts/main/outputTables.rgg`.
- Output path typically under `Model_output/<scenario-name>/`.
- DTO-backed output structures exist under `Scripts/dataModels/`.
- Persistent diagnostics are DTO-backed tables separate from primary biological results. `outputLeafGrowthDiagnostics`, `outputAppleDevelopmentDiagnostics`, `outputCarbonTransportDiagnostics`, and `outputWaterFluxSolverDebug` default to false; the first three write CSV and metadata pairs under `diagnostics/`, while the compatible water-solver stream remains at the output root.
- CellML fruit diagnostics are opt-in and write `diagnostics/cellml_fruit_debug.csv` plus metadata. The standard fruit table remains available only for scientifically supported mapped fields; CellML-specific state and solver fields stay in the diagnostic stream.

## Unit and schema expectations
- Keep units explicit and consistent (e.g., mg vs g, MPa conventions).
- Keep indexed DTO properties unique and contiguous. The maintained plant schema is checked by `python3 tests/diagnosis/check_output_dto_schema.py`.
- Select CSV data by header name rather than numeric position. In the plant table, zonal `meanAnet`, `meanLeafWaterPotential`, and `meanGs` fields now separate `intWaterPotential_4` from `sugarConcentration_1`.
- When `outputIndividualLeaf` and the organ-array schedule are active, `leafArray_<outputTable_name>.csv` exposes `PAnet`/`Anet` in umol CO2 m-2 s-1, `GSWpm`/`GSWa` in m s-1, and `gs` in mol m-2 s-1 for each selected reportable leaf.
- Hydraulic solver internals belong to the optional `waterFluxSolverDebug_<outputTable_name>.csv` stream; they are not standard plant-table columns.
- Avoid silent unit changes in existing columns.

## Fragile/easy-to-confuse settings
- JSON booleans must be real booleans (not strings).
- `rootBiomassInitMode` (model options) vs `rootWoodRefMode` (initial conditions) are different controls.
- Validation or low-core paths may constrain a requested GPU backend, but must not silently replace empirical, surrogate, or direct-input modes with CPU.
- Legacy `useFluxLightModel=false/true` maps to `cpu/gpu` with a deprecation warning; a present `lightInterceptionMode` is authoritative.
- Selecting `module_configuration.fruitModule="cellmlFruit"` requires the immutable model JAR in the active GroIMP `ext/` path and an existing Commons Math 3 provider. Machine-specific absolute JAR paths are not scenario configuration.
