# Single-leaf soluble/starch validation

Run:

    python tests/validation/run_single_leaf_carbon.py

The runner derives temporary headless configs from the maintained singleLeaf,
Fuji-parameter, and single-leaf initial-condition files. It imposes common-pool
phloem sugar mass fractions of 0.05, 0.10, and 0.20 g sugar per g phloem sap
for seven fixed 14 h-light / 10 h-dark days. The temporary inputs are removed;
the daily summary and per-treatment logs remain in this directory, and the
normal run snapshots remain under Model_output/singleLeafCarbon_cp*/.

The fixture explicitly uses baselineAssimilationToStarchFraction=0.125 only as
a provisional mechanism-test value. Starch photosynthetic feedback is disabled
so this first test isolates pool turnover and phloem source response.

Loading-capacity architecture is checked separately with:

    python tests/validation/run_single_leaf_loading_capacity.py

It repeats Cp 0.05, 0.10, and 0.20 with the ceiling disabled and with one
clearly test-only value. It verifies that disabled results are unchanged,
`sourceLoading(Cp)` is unchanged, actual loading remains potential times the
source factor, and capped carbon remains in the leaf pools.

After that pool test passes, run the separable feedback stage:

    python tests/validation/run_single_leaf_starch_feedback.py

It compares unchanged `starchAcclimation` with experimental
`carbohydrateExcessAcclimation`, checking that starch-only target feedback
plateaus after starch saturation while the weighted soluble excess can keep
the combined target responsive.

The 24 h integration seam for both carbon paths is:

    python tests/validation/run_leaf_carbon_whole_plant_smoke.py

This runs apple through CTRAM and grapevine through common-pool allocation,
checking finite non-negative pools, closure, and at most one commit per step.

The authoritative normal-workflow robustness suite is:

    python tests/validation/run_single_leaf_carbon_robustness.py

It launches the same `tests/smoke_test/unitTest.sh Xrun` path used by normal
headless scenarios. It writes seven-dawn trajectories for Cp 0.05 and 0.20
from initial starch fractions 0.1, 0.5, and 0.8; runs the 2 d low / 3 d high /
3 d low reversible boundary; and checks 10 h and 14 h photoperiods plus a
controlled sunny, cloudy-above-compensation, cloudy-below-compensation, and
true-night intervals. A photoperiod hour below `LIGHT_THRESHOLD` must remain
daytime, and negative accepted net assimilation must be charged exactly once.
The imposed boundary controls
source loading only, so every committed row must report zero maintenance from
phloem. The diagnostic's capacity-overflow column now means carbon retained
above the nominal reserve target, not carbon removed from the model.

No lightweight parameterised GroIMP Goal definitions are present in the
current project source. Interactive use should therefore launch the generated
normal scenario inputs with the same Xrun command rather than duplicating the
carbon logic in UI-specific Goal code. Retain those inputs with:

    python tests/validation/run_single_leaf_carbon_robustness.py --keep-configs

For example, the retained reversible case can then be repeated with:

    bash tests/smoke_test/unitTest.sh Xrun default 192 model.options.singleLeafCarbon.cpSwitch.json

The reduced whole-tree capacity diagnosis is:

    python tests/validation/run_leaf_loading_whole_tree_diagnosis.py

It compares no-fruit and high-crop FOPS states with the capacity disabled and
one high-crop mechanism-test run at 0.02 h-1. Results are distributional and
exclude empty-source rows from the low/high-Cp compensation comparison. The
finite cap is not an apple calibration.

No automated GroIMP save/reload continuation regression exists yet. Pool,
initialization-flag, and feedback fields are non-transient graph state intended
for continuation, but this README does not claim persistence is validated.
