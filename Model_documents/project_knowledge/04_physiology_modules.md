# Physiology modules summary

## Radiation interception
- `calcLightInterception` is the independent master switch; `lightInterceptionMode` selects `cpu`, `gpu`, `empiricalRegression`, `surrogateModel`, or `directInput`.
- CPU and GPU use the existing GroIMP ray tracers. Reduced modes populate the same normalized organ-light state without building or computing a ray-tracing scene.
- Empirical and surrogate providers must declare response units, resolution, version, supported organ types and predictors. In leaf gas-exchange test scenarios, `directInput` needs no separate light asset: it converts `globalRadiation` with environmental `fPAR` exactly once and does not use ray tracing. Generic `directInput` remains file-backed. A missing capability is an initialization error in strict mode.
- Existing Python `.pkl` artifacts under `SurrogateModel/` are not executable by the Java/GroIMP runtime and require conversion plus a verified feature manifest before they can be used.
- The maintained Beer-Lambert example predicts `relativePAR = Ctop * exp(-k * LAI_above + beta_z * height)`. `LAI_above` is dimensionless eligible leaf area strictly above a target divided by `focalArea`; equal-height leaves share a cumulative value. Its initial height term is disabled and its coefficients are provisional.
- Field clone/shading behavior is sensitive to `useShadingFactor` and clone settings.
- `useShadingFactor` remains a correction mechanism and never selects an interception backend.

Every backend must preserve the existing result contract: `incPARm2` is incident PAR in micromoles per square metre per second; `absPAR` and `absFarRed` are total organ absorption in micromoles per second; `abs` is total absorbed radiation represented by the model in micromoles per second; and `absm2` is that total per organ area in micromoles per square metre per second. `fpar` and `fabs` remain the existing dimensionless relative incident-PAR and total-absorption measures. Providers must not apply organ area, absorptance, shading factors, or unit conversions twice.

## Photosynthesis and transpiration
- Extended FvCB-style gas exchange computes potential and actual rates.
- Leaf temperature/stomata/transpiration are coupled to environment forcing.
- Actual transpiration can be throttled by hydraulic stress feedback.

## Water transport
- Tardieu-Davies-inspired hydraulic resistance approach from soil-root-xylem-leaf.
- Uses leaf/root water potential and conductance logic; optional ABA involvement by mode.

## Carbon allocation and transport
- Two major pathways:
  - common assimilate pool (source/sink equilibrium style).
  - CTRAM/phloem-transport mode with explicit transport equations and metamer graph routing.
- Module toggle: `useCTRAM`.

## Fruit growth, sugar, and acid logic
- `fruitModule` maps `simpleFruit` to `SimpleFruit`, `complexBerry` to `ComplexBerry`, `virtualFruit` to `VirtualFruit`, and `cellmlFruit` to `CellmlFruit` through `FruitCreator`.
- `simpleFruit` supplies only dry-matter/carbon demand; sugar/water dynamics belong to the detailed complex, virtual, and CellML services. `CellmlFruit` uses the external `SugarEbmSuperset` numerical backend while remaining a normal graph organ.
- JFruit2-linked output mapping has compatibility caveats (ctcs vs sugar mass reconstructions).

## Key assumptions and simplifications
- Many modules are switchable and may be bypassed in fast validation mode.
- Validation mode may constrain a requested GPU backend for runtime portability but preserves explicitly selected reduced modes.
- Some pathways are species/scenario specific and not universally active.
