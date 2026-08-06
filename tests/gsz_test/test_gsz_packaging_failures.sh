#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

ARCHIVE="${REPO_ROOT}/Scripts/Scripts.gsz"
PACKAGER="${REPO_ROOT}/bash_scripts/zip_groimp.sh"
VALIDATOR="${REPO_ROOT}/tests/gsz_test/validate_gsz_structure.sh"

[[ -s "${ARCHIVE}" ]] || {
  echo "ERROR: A valid baseline archive is required for the negative test" >&2
  exit 1
}
"${VALIDATOR}" "${ARCHIVE}"
BEFORE_SHA="$(sha256sum "${ARCHIVE}" | awk '{print $1}')"

set +e
GSZ_TEST_CORRUPT_TEMP_ARCHIVE=1 "${PACKAGER}"
FAILURE_CODE=$?
set -e

if [[ "${FAILURE_CODE}" -eq 0 ]]; then
  echo "ERROR: Deliberately corrupted temporary archive unexpectedly packaged successfully" >&2
  exit 1
fi

AFTER_SHA="$(sha256sum "${ARCHIVE}" | awk '{print $1}')"
if [[ "${BEFORE_SHA}" != "${AFTER_SHA}" ]]; then
  echo "ERROR: Failed packaging replaced the last valid Scripts.gsz" >&2
  exit 1
fi

"${VALIDATOR}" "${ARCHIVE}"
echo "Negative packaging test passed:"
echo "  corrupted temporary archive exit code: ${FAILURE_CODE}"
echo "  valid archive preserved: ${AFTER_SHA}"
