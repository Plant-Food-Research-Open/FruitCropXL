# Model architecture and execution flow

## High-level execution sequence
1. `init()` in `Scripts/main/main.rgg` resets graph/state and loads scenario/config.
2. Simulation services are selected via factories (simRun, updates, initiation, develop).
3. Each step executes update logic (`updatesService`) and optional development logic (`developService`) depending on options.
4. Output tables/charts and snapshots are emitted per output controls.

## Key object/module classes in practice
- Core graph objects: plant organs + structural modules under `Scripts/organs/`.
- Service abstraction pattern:
  - `UpdatesServiceFactory` -> species/special-scenario specific update implementation.
  - `DevelopServiceFactory` -> species/variation specific development implementation.
  - `FruitCreator` -> the selected `FruitService`, including `CellmlFruit` when `module_configuration.fruitModule="cellmlFruit"`.
- Loader/config classes concentrate in `Scripts/config/modelOptions.rgg` + parameter modules.

## Module switching logic
- Scenario JSON (`model.options.*.json`) keys drive switching:
  - species and initiation method.
  - special scenario override.
  - module complexity toggles (root/leaf/fruit, CTRAM, etc.).
- `special_scenario` can override species-default update path.
- Unknown/unsupported combinations fall back to default apple services.

## Static vs dynamic architecture
- `useStaticArc` and related functionality switches control whether topology remains fixed.
- Dynamic mode uses develop modules to add/modify organs through RGG rules.
- Architecture can come from coded initiation, CSV readers, or reconstruction modules.

## Practical integration notes
- Keep insertion points aligned with call graph docs and existing service dispatch.
- Prefer minimal changes in specific module variants over global rewiring.
- External numerical models remain plain Java backends owned by graph organs; they are not GroIMP graph nodes and must not advance from output getters.
