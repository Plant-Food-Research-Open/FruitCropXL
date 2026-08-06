#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  bash tests/diagnosis/grep_compile_errors.sh [log_file]

Behavior:
  - If a log file is provided, scan that file.
  - Otherwise, pick the newest likely GroIMP/unit-test log from:
      1. /tmp
      2. tests/validation

Matches:
  - Semantic error
  - could not be opened
  - No method named
  - No variable named
  - No class named
  - No field named
  - could not be resolved
  - Exception in phase 'semantic analysis'
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

pick_latest_log() {
  {
    find /tmp -maxdepth 1 -type f \
      \( -name '*.log' -o -name '*.txt' \) \
      | rg 'apple_leaf_inspect|fruitcropxl|groimp|validation|unit_test'
    find "${REPO_ROOT}/tests/validation" -maxdepth 1 -type f -name '*.log'
  } 2>/dev/null \
    | xargs -r ls -1t 2>/dev/null \
    | head -n 1
}

LOG_FILE="${1:-}"
if [[ -z "${LOG_FILE}" ]]; then
  LOG_FILE="$(pick_latest_log)"
fi

if [[ -z "${LOG_FILE}" ]]; then
  echo "No candidate log file found." >&2
  exit 1
fi

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "Log file not found: ${LOG_FILE}" >&2
  exit 1
fi

echo "Log: ${LOG_FILE}"
echo

PATTERN='Semantic error|could not be opened|No method named|No variable named|No class named|No field named|could not be resolved|Exception in phase .semantic analysis.'

if rg -n -C 1 "${PATTERN}" "${LOG_FILE}"; then
  if [[ "${STRICT_COMPILE_SCAN:-0}" == "1" ]]; then
    echo "Compile-style semantic errors matched." >&2
    exit 1
  fi
else
  echo "No compile-style semantic errors matched."
fi
