#!/usr/bin/env bash
set -euo pipefail

SCENARIO="${1:-default}"
NUM_STEPS="${2:-2}"
MODEL_OPTIONS="${3:-model.options.default.json}"
ARCHIVE_RUNNER="${ARCHIVE_RUNNER:-direct}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 \
  && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi
cd "${REPO_ROOT}"

ARCHIVE="${REPO_ROOT}/Scripts/Scripts.gsz"
METADATA_SOURCE="${GSZ_METADATA_SOURCE:-head}"
LOG_DIR="${REPO_ROOT}/Model_output/logs"
LOG="${LOG_DIR}/groimp_archive_${SCENARIO}.log"
mkdir -p "${LOG_DIR}"
: > "${LOG}"

bash tests/gsz_test/validate_gsz_structure.sh \
  "--metadata-source=${METADATA_SOURCE}" "${ARCHIVE}"

case "${ARCHIVE_RUNNER}" in
  direct)
    COMMAND=(
      env ARCHIVE_TEST=1
      bash tests/smoke_test/unitTest.sh
      Xrun "${SCENARIO}" "${NUM_STEPS}" "${MODEL_OPTIONS}"
    )
    ;;
  apptainer)
    COMMAND=(
      env "PROJECT_ENTRY_HOST=${ARCHIVE}"
      bash tests/validation/run_groimp_tests.sh
      XrunValidationTests "${SCENARIO}" "${NUM_STEPS}" "${MODEL_OPTIONS}"
    )
    ;;
  *)
    echo "ERROR: ARCHIVE_RUNNER must be 'direct' or 'apptainer': ${ARCHIVE_RUNNER}" >&2
    exit 2
    ;;
esac

echo "Running functional Scripts.gsz validation:"
echo "  runner  : ${ARCHIVE_RUNNER}"
echo "  scenario: ${SCENARIO}"
echo "  steps   : ${NUM_STEPS}"
echo "  archive : ${ARCHIVE}"
echo "  project : ${METADATA_SOURCE}"
printf '  command :'
printf ' %q' "${COMMAND[@]}"
echo

set +e
"${COMMAND[@]}" 2>&1 | tee "${LOG}"
EXIT_CODE=${PIPESTATUS[0]}
set -e

echo "Archive GroIMP exit code: ${EXIT_CODE}"
echo "Archive log: ${LOG}"
exit "${EXIT_CODE}"
