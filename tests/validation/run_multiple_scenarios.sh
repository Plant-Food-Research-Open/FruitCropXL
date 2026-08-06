#!/usr/bin/env bash
set -euo pipefail

# Concurrency cap (default 2; override with env var: MAX_JOBS=4 bash tests/validation/run_multiple_scenarios.sh).
MAX_JOBS="${MAX_JOBS:-2}"

default_scenarios=(
  default
  antony-2010
  dai-2012-12L
  dai-2012-3L
  FOPS-satDryTest
  stormTest
)

steps=""
if (($# > 0)); then
  last="${!#}"
  if [[ "$last" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    steps="${last%.*}"
    mapfile -t scenarios < <(printf '%s\n' "${@:1:$(($#-1))}")
  else
    mapfile -t scenarios < <(printf '%s\n' "$@")
  fi
else
  mapfile -t scenarios < <(printf '%s\n' "${default_scenarios[@]}")
fi

LOG_DIR="tests/validation"
mkdir -p "${LOG_DIR}"

echo "==> Runner: tests/validation/run_like_github_actions.sh"
echo "==> MAX_JOBS=${MAX_JOBS}"
echo "==> Steps: ${steps:-<model default>}"
echo "==> Scenarios: ${scenarios[*]}"
echo "==> Logs: ${LOG_DIR}/<scenario>.log and Model_output/logs/groimp_<scenario>.log"

run_one() {
  local scen="$1"
  local steps_arg="$2"
  local log="${LOG_DIR}/${scen}.log"

  echo "=== [START] CI-equivalent ${scen} (steps=${steps_arg:-model default}, log=${log}) ==="

  (
    set -o pipefail
    if [[ -n "${steps_arg}" ]]; then
      bash tests/validation/run_like_github_actions.sh "${scen}" "${steps_arg}" 2>&1 | tee "${log}"
    else
      bash tests/validation/run_like_github_actions.sh "${scen}" 2>&1 | tee "${log}"
    fi
  )
}

pids=()
names=()

for s in "${scenarios[@]}"; do
  run_one "${s}" "${steps}" &
  pids+=("$!")
  names+=("${s}")

  while (( $(jobs -r -p | wc -l) >= MAX_JOBS )); do
    sleep 0.2
  done
done

failures=()
for i in "${!pids[@]}"; do
  pid="${pids[$i]}"
  scen="${names[$i]}"
  if ! wait "${pid}"; then
    failures+=("${scen}")
  fi
done

if ((${#failures[@]})); then
  echo ""
  echo "Some scenarios failed:"
  for f in "${failures[@]}"; do
    echo "   - ${f} (see ${LOG_DIR}/${f}.log and Model_output/logs/groimp_${f}.log)"
  done
  exit 1
else
  echo ""
  echo "All scenarios completed successfully."
fi
