# Packaged GroIMP project tests

This directory owns structural, metadata-source, reproducibility, timeout, and
functional tests for `Scripts/Scripts.gsz`.

Run from the repository root:

```bash
bash bash_scripts/zip_groimp.sh
bash bash_scripts/zip_groimp.sh --metadata-source=worktree
bash tests/gsz_test/validate_gsz_structure.sh
bash tests/gsz_test/test_gsz_metadata_source.sh
bash tests/gsz_test/check_gsz_reproducibility.sh
bash tests/gsz_test/test_gsz_packaging_failures.sh
bash tests/gsz_test/run_archive_test.sh default
```

The ordered pre-commit workflow is:

```bash
bash tests/gsz_test/finalise_repository.sh
```

It includes the local Apptainer acceptance scenario unless explicitly skipped
with `FINALISE_SKIP_LOCAL_ACCEPTANCE=1`. The lower-level timeout launcher is
`tests/gsz_test/test_run_gsz_headless.sh`.

Normal scenario validation remains under `tests/validation/`; the portable
direct-Java runner is `tests/smoke_test/unitTest.sh`.
