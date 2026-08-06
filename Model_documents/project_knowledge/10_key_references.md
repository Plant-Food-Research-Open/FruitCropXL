# Key references (local PDFs) for FruitCropXL support

> Note: this summary is grounded in in-repo reference file names plus model documentation/readme context. Full-text extraction tooling for PDF parsing may be unavailable in minimal environments.

## Zhu et al. 2018 — 3-D functional-structural grapevine model
**File:** `Model_documents/GrapevineXL/Zhu-2018-A 3-D functional–structural grapevine.pdf`  
This is the foundational grapevine FSPM reference for object structure, organ/process coupling, and overall model framing that FruitCropXL extends. Use it when answering questions about baseline architecture objects, process integration philosophy, and original grapevine assumptions.

## Zhu et al. 2019 — Modelling grape growth under source-sink interactions
**File:** `Model_documents/GrapevineXL/Zhu_2019-Modelling-grape-growth.pdf`  
Use this when support requests focus on growth trajectories, sink demand, berry development timing, and how source limitations are represented in grape simulations.

## Zhu et al. 2021 — Carbon transport / phloem transport integration
**File:** `Model_documents/GrapevineXL/Zhu-2021-carbon-transport.pdf`  
This is the primary citation for CTRAM-like transport behavior in the repo. Consult it for mechanistic carbon routing, source-sink transport equations, and transport-mode assumptions.

## Gas exchange and water flux reference package
**File:** `Model_documents/GrapevineXL/gas exchange with water flux copy.pdf`  
Use this for coupled photosynthesis-transpiration-hydraulic logic, especially where stomatal conductance and leaf/plant water potential feedback are discussed.

## Seasonal yield variation reference
**File:** `Model_documents/GrapevineXL/Quantifying_the_seasonal_variations_in_grapevine_yield.pdf`  
Use this when discussing seasonal yield component drivers, scenario calibration targets, or year-to-year variability interpretation.

## APSIM perennial fruit-crop modelling context
**File:** `Model_documents/GrapevineXL/Developing_perennial_fruit_crop_models_in_APSIM.pdf`  
Useful for cross-framework reasoning and conceptual comparisons between FruitCropXL modules and broader perennial-crop modelling strategies.

## Supporting supplements and figures
**Files:**
- `Supplementary-Zhu-2018-3-D functional–structural grapevine.pdf`
- `Supplementary-zhu-2019-modelling-grape-growth.pdf`
- `Fig. 2 Carbon flux and berry development 2017.11.14.pdf`

Use these when detailed parameterization rationale, calibration figures, or method supplements are needed beyond main paper text.

## XL/GroIMP language references for implementation details
**Files:**
- `Model_documents/softdoc/GroIMP_training/Session_3_radiation_model_and_query/xl13query.pdf`
- `Model_documents/softdoc/Manual/henkeGroIMP1.6.pdf`
- `Model_documents/softdoc/notes and diagram/GroIMP_XL_Tips.txt`

Consult these for syntax/semantics questions (graph queries, rule behavior, turtle branch logic) and platform-specific implementation constraints.
