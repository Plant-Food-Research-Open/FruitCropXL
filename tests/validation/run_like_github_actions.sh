#!/usr/bin/env bash
set -euo pipefail

SCENARIO="${1:-stormTest}"
NUM_STEPS="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_PATH="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  REPO_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi
cd "${REPO_PATH}"

[[ -f .env ]] && . .env

mkdir -p Model_output/logs

GLOBAL_FILE="Scripts/config/globalParameters.rgg"
GLOBAL_BACKUP="$(mktemp)"
cp "${GLOBAL_FILE}" "${GLOBAL_BACKUP}"

restore_global() {
  cp "${GLOBAL_BACKUP}" "${GLOBAL_FILE}"
  rm -f "${GLOBAL_BACKUP}"
}
trap restore_global EXIT

sed -i \
  -e 's/static boolean shouldContinue = true;/static boolean shouldContinue = false;/' \
  -e 's/global boolean shouldContinue = true;/global boolean shouldContinue = false;/' \
  "${GLOBAL_FILE}"
if ! grep -qE '(static|global) boolean shouldContinue = false;' "${GLOBAL_FILE}"; then
  echo "Failed to patch shouldContinue=false in ${GLOBAL_FILE}" >&2
  exit 1
fi

LOG="Model_output/logs/groimp_${SCENARIO}.log"
rm -f "${LOG}"

CMD=(bash tests/validation/run_groimp_tests.sh XrunValidationTests "${SCENARIO}")
if [[ -n "${NUM_STEPS}" ]]; then
  CMD+=("${NUM_STEPS}")
fi

set +e
"${CMD[@]}" 2>&1 | tee "${LOG}"
EXIT_CODE=${PIPESTATUS[0]}
set -e

echo "GroIMP exit code: ${EXIT_CODE}"

grep -E "lightInterceptionMode(Requested|Resolved)" "${LOG}" || true

if [[ "${EXIT_CODE}" -ne 0 ]]; then
  if grep -q "Incompatible magic value .* java/util/prefs/XmlSupport" "${LOG}"; then
    echo "Detected known JVM preferences bug - treating run as success for CI-equivalent validation."
  else
    echo "GroIMP failed for another reason."
    exit "${EXIT_CODE}"
  fi
fi

if [[ ! -f "${LOG}" ]]; then
  echo "Expected log not found: ${LOG}" >&2
  exit 2
fi

if grep -qE \
  "Finished\. Result: Failures: [1-9][0-9]*|Failures: [1-9][0-9]*|java\.lang\.AssertionError:?|Columns not within discrepancy threshold" \
  "${LOG}"
then
  echo "Detected validation failures in log."
  exit 1
fi

if grep -qE "lightInterceptionModeResolved[[:space:]]*[:=][[:space:]]*gpu" "${LOG}"; then
	  echo "GPU light interception appears enabled in CI-equivalent validation log." >&2
	  exit 1
fi

if ! grep -qE "lightInterceptionModeResolved[[:space:]]*[:=][[:space:]]*cpu" "${LOG}"; then
  echo "CI-equivalent validation log did not confirm the resolved CPU light backend." >&2
  exit 1
fi

if [[ ! -s "Model_output/validation_test.xml" ]]; then
  echo "Warning: missing or empty JUnit report at Model_output/validation_test.xml"
fi

echo "CI-equivalent validation passed for scenario: ${SCENARIO}"
echo "Log: ${LOG}"
