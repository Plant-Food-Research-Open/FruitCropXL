# FruitCropXL public distribution

This repository owns public release/export content: selected model source,
scenarios, documentation and package/run tests. Canonical implementation
behaviour remains owned by repository 0.

- Key areas: `Scripts/`, `Model_scenarios/`, `Model_documents/`,
  `bash_scripts/`, `tests/gsz_test/`, `tests/smoke_test/` and
  `tests/validation/`.
- Establish canonical source commit and inclusion/exclusion scope before an
  export or public patch. Do not bring private paths, datasets, manuscript
  content or workspace-specific symlinks into the public tree.
- Treat `Scripts.gsz` as packaged output: check source/archive consistency and
  run relevant GSZ/smoke tests rather than manually patching it.
- Use `fruitcropxl-public-release`. Report provenance, changed public surface,
  release tests and any canonical/public drift; do not make the public tree the
  authority for a model behaviour change.
