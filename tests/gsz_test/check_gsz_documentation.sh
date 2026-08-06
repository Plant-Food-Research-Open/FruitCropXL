#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

REQUIRED_COMMANDS=(
  "bash bash_scripts/zip_groimp.sh"
  "bash bash_scripts/zip_groimp.sh --metadata-source=worktree"
  "bash tests/gsz_test/validate_gsz_structure.sh"
  "bash tests/gsz_test/test_gsz_metadata_source.sh"
  "bash tests/gsz_test/finalise_repository.sh"
)

DOCUMENTS=(
  "tests/gsz_test/README.md"
  "Model_documents/config-execution/execution.md"
)

for DOCUMENT in "${DOCUMENTS[@]}"; do
  [[ -s "${DOCUMENT}" ]] || fail "Required packaging documentation is missing or empty: ${DOCUMENT}"
done

for COMMAND in "${REQUIRED_COMMANDS[@]}"; do
  rg -Fq "${COMMAND}" "${DOCUMENTS[@]}" \
    || fail "Packaging documentation does not mention canonical command: ${COMMAND}"
done

if rg -n \
  'zip_groimp\.sh[[:space:]]+[01]|Only update rgg files in Scripts\.gsz|Rename Scripts\.gsz to a zip|packaged from the Git index|come from the Git index' \
  "${DOCUMENTS[@]}"; then
  fail "Documentation still describes the obsolete incremental archive updater"
fi

bash -n \
  bash_scripts/gsz_source_manifest.sh \
  bash_scripts/stage_gsz_sources.sh \
  bash_scripts/zip_groimp.sh \
  tests/gsz_test/validate_gsz_structure.sh \
  tests/gsz_test/check_gsz_reproducibility.sh \
  tests/gsz_test/test_gsz_packaging_failures.sh \
  tests/gsz_test/test_gsz_metadata_source.sh \
  tests/gsz_test/run_archive_test.sh \
  tests/gsz_test/finalise_repository.sh \
  bash_scripts/commit_project_files.sh

echo "Scripts.gsz documentation consistency check passed."
