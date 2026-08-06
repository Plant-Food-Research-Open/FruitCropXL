# Species and modularity switches

## Grapevine vs apple
- Species is selected in `module_configuration.species`.
- Update and development services dispatch by species with scenario overrides.
- Species-specific initiation/develop/update modules live in `Scripts/alterModules/`.

## Root model options
- `useComplexRoot=false`: simple layered/aggregated root representation.
- `useComplexRoot=true`: more detailed root architecture pathways.
- Root biomass initialization policy is controlled by `rootBiomassInitMode` (model options) plus structural-root keys in initial conditions.

## Light and carbon toggles
- Light controls: `calcLightInterception`, `lightInterceptionMode`, `useShadingFactor`, and radiation source toggles. Canonical modes are `cpu`, `gpu`, `empiricalRegression`, `surrogateModel`, and `directInput`.
- Empirical and surrogate modes require compatible declared assets and organ capabilities; Python `.pkl` files are not Java/GroIMP runtime artifacts. The leaf gas-exchange test branch of `directInput` converts `globalRadiation` with environmental `fPAR` exactly once and needs no separate light asset; generic `directInput` remains file-backed.
- Carbon controls: `calcCarbonAllocation`, `useCTRAM`.
- PT controls: `calcPotential_PT`, `calcActual_PT`.

## Architecture loading options
- Static vs dynamic is controlled by model-functionality switches.
- Initiation can use architecture readers (`ArchReader` variants) or coded organ generation.
- Scenarios can point to CSV architecture sources via `scenario_required_files`.

## Species-specific development conventions
- Apple and grapevine have dedicated develop/update modules and planner conventions.
- Historical compatibility patterns (e.g., wholePlant/wholeTree normalization) are preserved for legacy scenarios.
- Avoid changing module-selection fallback behavior unless explicitly required.

## Fruit-module selection
- `module_configuration.fruitModule` retains the existing fruit factory path. Supported current values include `simpleFruit`, `complexBerry`, `virtualFruit`, and `cellmlFruit`.
- `cellmlFruit` constructs a graph-organ `CellmlFruit` with one independent `SugarEbmFruitBackend`; the generated CellML model in the external JAR is numerical state, not a graph node.
- Keep a normal plant scenario's species/initiation/update path when selecting `cellmlFruit`. The isolated fixture's `special_scenario="cellmlFruit"` is only for its reduced deterministic test path.
