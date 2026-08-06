#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_PATH}"

SCENARIOS=("dai-2012-12L" "dai-2012-3L" "antony-2010")
#SCENARIOS=("antony-2010")
#SCENARIOS=("default")

MAX_JOBS_LOCAL="${MAX_JOBS:-1}"
TIMEOUT_SECS="${TIMEOUT_SECS:-3600}"

if [[ "${1:-}" != "--run" ]]; then
  echo "Refusing to run without explicit --run flag." >&2
  echo "Use: bash tests/validation/check_dai_2012_12L_and_3L.sh --run [steps]" >&2
  exit 2
fi
shift

if [[ "$#" -gt 1 ]]; then
  echo "Too many arguments." >&2
  echo "Use: bash tests/validation/check_dai_2012_12L_and_3L.sh --run [steps]" >&2
  exit 2
fi

STEPS_ARG="${1:-}"
LOG_DIR="tests/validation"
SCENARIO_SLUG="$(printf '%s\n' "${SCENARIOS[@]}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_' | sed 's/^_//; s/_$//')"
COMBINED_LOG="${LOG_DIR}/${SCENARIO_SLUG:-multi}_multi.log"

mkdir -p "${LOG_DIR}"
rm -f "${COMBINED_LOG}"

echo "Running DAI validation via run_multiple_scenarios.sh -> run_like_github_actions.sh"
echo "  scenarios     : ${SCENARIOS[*]}"
echo "  MAX_JOBS      : ${MAX_JOBS_LOCAL}"
echo "  timeout (sec) : ${TIMEOUT_SECS}"
echo "  steps         : ${STEPS_ARG:-<model default>}"
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
  CI_LOG="Model_output/logs/groimp_${scen}.log"
  if [[ ! -s "${LOG_PATH}" ]]; then
    echo "Missing or empty scenario log: ${LOG_PATH}" >&2
    exit 1
  fi
  if [[ ! -s "${CI_LOG}" ]]; then
    echo "Missing or empty CI-equivalent scenario log: ${CI_LOG}" >&2
    exit 1
  fi
done

echo "${SCENARIOS[*]} validation passed."
echo "  command    : MAX_JOBS=${MAX_JOBS_LOCAL} bash tests/validation/run_multiple_scenarios.sh ${SCENARIOS[*]}${STEPS_ARG:+ ${STEPS_ARG}}"
echo "  combined   : ${COMBINED_LOG}"
for scen in "${SCENARIOS[@]}"; do
  echo "  scenario   : ${LOG_DIR}/${scen}.log"
  echo "  ci-log     : Model_output/logs/groimp_${scen}.log"
done
