#!/usr/bin/env bash
set -euo pipefail

################################################################################
# unitTest.sh
#
# Minimal, portable smoke test runner for FruitCropXL / functional-structural-fruit-crop-model.
#
# Direct Java invocation of GroIMP core.jar (no apptainer).
#
# This is not equivalent to GitHub Actions validation. For CI-equivalent local
# validation, use:
#   bash tests/validation/run_like_github_actions.sh <scenario>
#
# NOTE (important):
#   -XmodelOptions expects a MODEL OPTIONS FILE NAME (e.g. model.options.default.json),
#   not an absolute path. The model resolves it internally (typically under Model_scenarios/).
################################################################################

# Always load .env if present
[[ -f .env ]] && . .env

################################################################################
# Repo root resolution (robust)
################################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_PATH="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  # fallback: assume script lives in tests/smoke_test/
  REPO_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi

################################################################################
# Configurable locations (override in .env or environment)
################################################################################
GROIMP_DIR_DEFAULT="/usr/share/GroIMP"
GROIMP_DIR="${GROIMP_DIR:-${GROIMP_DIR_DEFAULT}}"
GROIMP_CORE_JAR="${GROIMP_CORE_JAR:-${GROIMP_DIR}/core.jar}"
JAVA_BIN="${JAVA_BIN:-java}"

if [[ "${ARCHIVE_TEST:-0}" == "1" ]]; then
  PROJECT_FILE_DEFAULT="${REPO_PATH}/Scripts/Scripts.gsz"
else
  PROJECT_FILE_DEFAULT="${REPO_PATH}/Scripts/project.gs"
fi
PROJECT_FILE="${PROJECT_FILE:-${PROJECT_FILE_DEFAULT}}"

# Default model options file name (matches run_groimp_tests.sh convention)
MODEL_OPTIONS_DEFAULT="model.options.default.json"

################################################################################
# Functions
################################################################################
usage() {
  cat <<'EOF'
###############################################################
Help: unitTest.sh

Description:
  Runs a small direct-Java smoke test for the functional structural fruit crop
  model using GroIMP core.jar (no apptainer).

  This is not equivalent to GitHub Actions validation.
  For CI-equivalent local validation, use:
    bash tests/validation/run_like_github_actions.sh <scenario>

Usage:
  ./unitTest.sh [test_type] [validation_scenario] [num_steps] [model_options_file]

Parameters:
  test_type:
    GroIMP headless mode selector (default: XrunTests)
    (passed as -<test_type>)
  validation_scenario:
    Scenario key/name used by your model's validation test switch (default: default)
  num_steps:
    Optional integer number of simulation steps. Decimal values are truncated.
  model_options_file:
    Optional model options FILE NAME override (default: model.options.default.json).
    IMPORTANT: Provide a FILE NAME, not a full path.
    The model typically resolves this under Model_scenarios/.

Environment overrides:
  GROIMP_DIR        : GroIMP installation directory (default: /usr/share/GroIMP)
  GROIMP_CORE_JAR   : Full path to core.jar (overrides GROIMP_DIR/core.jar)
  JAVA_BIN          : java executable (default: java)
  PROJECT_FILE      : GroIMP project entry to run
                      default: ./Scripts/project.gs
                      with ARCHIVE_TEST=1: ./Scripts/Scripts.gsz
  MODEL_OPTIONS     : model options file name (same meaning as 4th arg)
  ARCHIVE_TEST      : set to 1 to default PROJECT_FILE to Scripts/Scripts.gsz

Examples:
  ./unitTest.sh
  ./unitTest.sh XrunTests default 48
  ./unitTest.sh XrunTests default 24 model.options.default.json
  MODEL_OPTIONS=model.options.default.json ./unitTest.sh XrunTests default 24
  ARCHIVE_TEST=1 ./unitTest.sh

###############################################################
EOF
}

fail() { echo "❌ $*" >&2; exit 1; }

repair_unwritable_run_config_dir() {
  local output_root="${REPO_PATH}/Model_output"
  local run_config_dir="${output_root}/${VALIDATION_SCENARIO}/run-config"
  local preserved_dir
  local stamp

  [[ -d "${run_config_dir}" && ! -w "${run_config_dir}" ]] || return 0
  stamp="$(date +%Y%m%d-%H%M%S)"
  preserved_dir="${run_config_dir}.unwritable-${stamp}-$$"
  echo "⚠️  Replacing non-writable run snapshot directory:"
  echo "   old: ${run_config_dir}"
  echo "   preserved as: ${preserved_dir}"

  mv -- "${run_config_dir}" "${preserved_dir}" \
    || fail "Could not move non-writable run-config directory: ${run_config_dir}"
  mkdir -p "${run_config_dir}" \
    || fail "Could not create writable run-config directory: ${run_config_dir}"
}

################################################################################
# Argument Parsing
################################################################################
if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
  usage
  exit 0
fi

TEST_TYPE="${1:-XrunTests}"
VALIDATION_SCENARIO="${2:-default}"
NUM_STEPS="${3:-}"
NUM_STEPS="${NUM_STEPS%.*}"  # truncate decimals

# Allow override via env (MODEL_OPTIONS) or 4th arg; default to model.options.default.json
MODEL_OPTIONS="${MODEL_OPTIONS:-${4:-${MODEL_OPTIONS_DEFAULT}}}"

# If a user accidentally passes a path, keep only basename (model expects file name)
MODEL_OPTIONS_BASENAME="$(basename "${MODEL_OPTIONS}")"

################################################################################
# Runtime home/prefs isolation (avoid GroIMP/Java prefs lock contention)
################################################################################
if [[ -n "${GROIMP_RUNTIME_HOME:-}" ]]; then
  RUNTIME_HOME="${GROIMP_RUNTIME_HOME}"
  RUNTIME_HOME_IS_TEMP=0
else
  RUNTIME_HOME="${REPO_PATH}/tmp/groimp_home_${USER:-user}_$$"
  RUNTIME_HOME_IS_TEMP=1
fi
mkdir -p "${RUNTIME_HOME}" \
         "${RUNTIME_HOME}/.java/.userPrefs" \
         "${RUNTIME_HOME}/.grogra.de-platform/log"
export HOME="${RUNTIME_HOME}"

cleanup_runtime_home() {
  if [[ "${RUNTIME_HOME_IS_TEMP}" == "1" && "${GROIMP_KEEP_RUNTIME_HOME:-0}" != "1" ]]; then
    rm -rf "${RUNTIME_HOME}"
  else
    echo "Keeping GroIMP runtime home: ${RUNTIME_HOME}"
  fi
}
trap cleanup_runtime_home EXIT

################################################################################
# Pre-flight checks
################################################################################
command -v "${JAVA_BIN}" >/dev/null 2>&1 || fail "JAVA_BIN not found/executable: ${JAVA_BIN}"
[[ -f "${GROIMP_CORE_JAR}" ]] || fail "GroIMP core.jar not found at: ${GROIMP_CORE_JAR} (set GROIMP_DIR or GROIMP_CORE_JAR)"
[[ -f "${PROJECT_FILE}" ]] || fail "Project file not found: ${PROJECT_FILE} (set PROJECT_FILE if needed)"
repair_unwritable_run_config_dir

# Confirm the options file exists where the model expects it (Model_scenarios/<file>)
MODEL_OPTIONS_EXPECTED_PATH="${REPO_PATH}/Model_scenarios/${MODEL_OPTIONS_BASENAME}"
[[ -f "${MODEL_OPTIONS_EXPECTED_PATH}" ]] || fail "Model options file not found: ${MODEL_OPTIONS_EXPECTED_PATH} (set MODEL_OPTIONS to a file name under Model_scenarios/)"

# Normalize model path: ensure trailing slash
MODEL_PATH="${REPO_PATH%/}/"

################################################################################
# Header
################################################################################
echo "📌 Running unit smoke test (direct Java, not CI-equivalent):"
echo "   → Repo path           : ${REPO_PATH}"
echo "   → Test Type           : ${TEST_TYPE}"
echo "   → Validation Scenario : ${VALIDATION_SCENARIO}"
[[ -n "${NUM_STEPS}" ]] && echo "   → Number of Steps     : ${NUM_STEPS}"
echo "   → Project file        : ${PROJECT_FILE}"
echo "   → Model options (name): ${MODEL_OPTIONS_BASENAME}"
echo "   → Model options (chk) : ${MODEL_OPTIONS_EXPECTED_PATH}"
echo "   → Runtime HOME        : ${RUNTIME_HOME}"

################################################################################
# Build direct Java command
################################################################################
JAVA_OPTS_DEFAULT=(
  -Djava.awt.headless=true
  "-Duser.home=${RUNTIME_HOME}"
  "-Djava.util.prefs.userRoot=${RUNTIME_HOME}/.java/.userPrefs"
  -Xms2g
  -Xss1m
  -XX:+UseSerialGC
  -XX:+UnlockDiagnosticVMOptions
  -XX:-TieredCompilation
  -XX:+AlwaysPreTouch
  -noverify
)

if [[ -n "${JAVA_OPTS-}" ]]; then
  # shellcheck disable=SC2206
  JAVA_OPTS_ARR=( ${JAVA_OPTS} )
else
  JAVA_OPTS_ARR=("${JAVA_OPTS_DEFAULT[@]}")
fi

CMD=(
  "${JAVA_BIN}"
  "${JAVA_OPTS_ARR[@]}"
  -jar "${GROIMP_CORE_JAR}"
  --headless
  "-${TEST_TYPE}"
  "-XmodelPath=${MODEL_PATH}"
  "-XvalidationTestScenario=${VALIDATION_SCENARIO}"
  "-XmodelOptions=${MODEL_OPTIONS_BASENAME}"
)

if [[ -n "${NUM_STEPS:-}" ]]; then
  CMD+=("-XrunEndSteps=${NUM_STEPS}")
fi

CMD+=("${PROJECT_FILE}")

################################################################################
# Run
################################################################################
echo "🚀 Starting Simulation..."
printf '🔍 Running command:'; printf ' %q' "${CMD[@]}"; echo
"${CMD[@]}"
echo "✅ Test completed successfully!"
