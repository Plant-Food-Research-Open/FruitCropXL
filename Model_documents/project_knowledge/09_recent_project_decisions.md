# Recent project decisions and stable rules

## Configuration and loader decisions
- Keep scenario/loader defaults compatibility-safe with localized fallback guards for optional keys.
- Keep model-options docs/templates synchronized when loader keys/defaults/categories change.
- Keep plant-parameters and initial-conditions docs/templates synchronized when their loader-facing keys change.

## Validation workflow decisions
- Hosted/cloud tasks: run only `tests/smoke_test/unitTest.sh` unless explicitly asked otherwise.
- Validation mode intentionally uses faster light/shading assumptions; do not assume full clone-field behavior there.
- Keep scenario validation in `tests/validation/`, portable smoke testing in
  `tests/smoke_test/`, diagnostic helpers in `tests/diagnosis/`, packaged
  project checks in `tests/gsz_test/`, and feature-owned CellML checks in
  `tests/cellml/`; do not add suffix copies such as `*.updated.sh` beside a
  canonical entry point.

## Knowledge-maintenance decisions
- Maintain topic-specific project notes and non-obvious agent lessons separately because they have different owners and purposes.
- Generate one shared broad-context bundle with `bash_scripts/update_project_knowledge.sh`; do not maintain several manually copied combined summaries.
- Edit focused notes or `recent-stable-lessons.md`, then regenerate. Never edit `generated_knowledge_bundle.md` directly.

## Execution entrypoint decisions
- Stable headless entrypoint is `Scripts/Scripts.gsz` for local validation/batch runs.
- Refresh `.gsz` before local archive-based validation after source edits.
- In hosted/cloud tasks, avoid modifying/regenerating `Scripts/Scripts.gsz` unless explicitly requested.

## Architecture and module-selection decisions
- Verify active loader path before editing loader logic (duplicate loader history exists).
- Normalize legacy planner target modes when needed for backward compatibility.
- Avoid query patterns that create Cartesian over-creation in initiation paths.

## Output and robustness decisions
- Preserve DTO index continuity and append fields at the end.
- Reset step-level transient outputs to avoid stale values.
- Guard sparse aggregate cases and null-root lookups in output table writes.

## Fruit and physiology-specific decisions
- Keep virtual-fruit sugar concentration outputs consistent with sugar-mass reconstruction rules.
- Maintain compatibility in fruit planning add/remove semantics and apple/grape-specific development paths.
