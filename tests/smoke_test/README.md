# Portable smoke test

`unitTest.sh` is the direct-Java GroIMP smoke-test runner. It does not require
Apptainer and defaults to `Scripts/project.gs`; set `ARCHIVE_TEST=1` to select
`Scripts/Scripts.gsz`.

Run from the repository root:

```bash
bash tests/smoke_test/unitTest.sh
bash tests/smoke_test/unitTest.sh Xrun default 2 model.options.default.json
ARCHIVE_TEST=1 bash tests/smoke_test/unitTest.sh Xrun default 2 model.options.default.json
```

Scenario validation and its fixtures remain under `tests/validation/`.
Packaged-project-specific checks are under `tests/gsz_test/`.
