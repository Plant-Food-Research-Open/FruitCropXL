#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_PATH}"

LOG_DIR="tests/validation"
#SCENARIOS=("FOPS-satDryTest")
#SCENARIOS=("FOPS-satDryTest" "stormTest" "default")
SCENARIOS=("FOPS-satDryTest" "default")
#SCENARIOS=("stormTest")
#SCENARIOS=("default")
FAIL_PATTERN="Finished\\. Result: Failures: [1-9][0-9]*|Failures: [1-9][0-9]*|java\\.lang\\.AssertionError:?|Columns not within discrepancy threshold"

# Default to serial execution because both runs can touch shared outputs/logs.
MAX_JOBS_LOCAL="${MAX_JOBS:-1}"
TIMEOUT_SECS="${TIMEOUT_SECS:-3600}"

if [[ "${1:-}" != "--run" ]]; then
  echo "Refusing to run without explicit --run flag." >&2
  echo "Use: bash tests/validation/check_fops_satdry_and_default.sh --run [steps]" >&2
  exit 2
fi
shift

if [[ "$#" -gt 1 ]]; then
  echo "Too many arguments." >&2
  echo "Use: bash tests/validation/check_fops_satdry_and_default.sh --run [steps]" >&2
  exit 2
fi

STEPS_ARG="${1:-}"

if [[ "${#SCENARIOS[@]}" -eq 0 ]]; then
  echo "SCENARIOS list is empty. Edit SCENARIOS=(...) and rerun." >&2
  exit 1
fi

SCENARIO_SLUG="$(printf '%s\n' "${SCENARIOS[@]}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_' | sed 's/^_//; s/_$//')"
COMBINED_LOG="${LOG_DIR}/${SCENARIO_SLUG:-multi}_multi.log"

mkdir -p "${LOG_DIR}"
rm -f "${COMBINED_LOG}"

echo "Running validation multi-scenario test via run_multiple_scenarios.sh"
echo "  scenarios     : ${SCENARIOS[*]}"
echo "  MAX_JOBS      : ${MAX_JOBS_LOCAL}"
echo "  timeout (sec) : ${TIMEOUT_SECS}"
if [[ -n "${STEPS_ARG}" ]]; then
  echo "  steps         : ${STEPS_ARG}"
else
  echo "  steps         : <model default>"
fi
echo "  combined log  : ${COMBINED_LOG}"

set +e
if [[ -n "${STEPS_ARG}" ]]; then
  timeout "${TIMEOUT_SECS}" env MAX_JOBS="${MAX_JOBS_LOCAL}" \
    bash tests/validation/run_multiple_scenarios.sh "${SCENARIOS[@]}" "${STEPS_ARG}" \
    2>&1 | tee "${COMBINED_LOG}"
else
  timeout "${TIMEOUT_SECS}" env MAX_JOBS="${MAX_JOBS_LOCAL}" \
    bash tests/validation/run_multiple_scenarios.sh "${SCENARIOS[@]}" \
    2>&1 | tee "${COMBINED_LOG}"
fi
RUN_EXIT=${PIPESTATUS[0]}
set -e

if [[ "${RUN_EXIT}" -ne 0 ]]; then
  echo "run_multiple_scenarios.sh failed with exit code ${RUN_EXIT}" >&2
  echo "See ${COMBINED_LOG}" >&2
  exit "${RUN_EXIT}"
fi

for scen in "${SCENARIOS[@]}"; do
  LOG_PATH="${LOG_DIR}/${scen}.log"
  if [[ ! -s "${LOG_PATH}" ]]; then
    echo "Missing or empty scenario log: ${LOG_PATH}" >&2
    exit 1
  fi

  if rg -qE "${FAIL_PATTERN}" "${LOG_PATH}"; then
    echo "Validation failure pattern detected in ${LOG_PATH}" >&2
    exit 1
  fi
done

echo "${SCENARIOS[*]} multi-scenario validation passed."
echo "  command    : MAX_JOBS=${MAX_JOBS_LOCAL} bash tests/validation/run_multiple_scenarios.sh ${SCENARIOS[*]}${STEPS_ARG:+ ${STEPS_ARG}}"
echo "  combined   : ${COMBINED_LOG}"
for scen in "${SCENARIOS[@]}"; do
  echo "  scenario   : ${LOG_DIR}/${scen}.log"
done
