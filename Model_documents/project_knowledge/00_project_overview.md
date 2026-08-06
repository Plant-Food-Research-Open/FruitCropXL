# FruitCropXL project overview

## What FruitCropXL is
FruitCropXL is a GroIMP XL/RGG-based functional-structural plant model (FSPM) for perennial fruit crops, implemented as object-based plant graphs with explicit organs (buds, leaves, internodes, flowers/fruits, fine roots, structural roots) and process modules (environment, phenology, carbon/water transport, management).

## What the project simulates
- 3D canopy architecture and light interception.
- Leaf gas exchange (photosynthesis/transpiration) and hydraulic feedback.
- Carbon allocation and optional phloem transport.
- Organ growth and development dynamics (initiation, update, develop loops).
- Management actions (twinning, pruning/planners).
- Scenario-driven multi-scale simulations from organ-level to canopy/field-level.

## Supported species and modules
- Primary species switches: `apple`, `grapevine`.
- Species-specific update/develop/integration paths selected by service factories.
- Optional module families: simple/complex roots, one selected fruit service (`simpleFruit`, `complexBerry`, `virtualFruit`, or the external-JAR-backed `cellmlFruit`), structural variation, light model options, static vs dynamic architecture.

## Modelling scales
- Time scale: hourly step updates through seasonal runs.
- Spatial scale: organ/metamer to whole plant to replicated field rows.
- Process coupling scale: organ-local states + plant/system-level resource transport.

## Major use cases
- Validation against published datasets/scenarios.
- Scenario testing for architecture, management, and environment combinations.
- Species comparison and module-configuration experiments.
- Batch/headless simulation workflows for reproducible outputs.
