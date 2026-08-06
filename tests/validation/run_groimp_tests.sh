#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_PATH="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
    REPO_PATH="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi
cd "${REPO_PATH}"

# Always load .env if present (even when args are passed).
[[ -f .env ]] && . .env

GROIMP_DIR="${GROIMP_DIR:-/usr/share/GroIMP}"
APPTAINER_IMAGE_PATH="${APPTAINER_IMAGE_PATH:-${REPO_PATH}/images/groimp.sif}"
PROJECT_ENTRY_HOST="${PROJECT_ENTRY_HOST:-${REPO_PATH}/Scripts/project.gs}"
PROJECT_ENTRY_HOST="$(realpath "${PROJECT_ENTRY_HOST}")"
PROJECT_ENTRY_REL="${PROJECT_ENTRY_HOST#${REPO_PATH}/}"
PROJECT_ENTRY_CONTAINER="/var/model/${PROJECT_ENTRY_REL}"

usage() {
    cat <<'EOF'
###############################################################
Help: run_groimp_tests.sh

Description:
  Runs a validation test for the functional structural fruit crop model.
  This is the canonical Apptainer runner used by GitHub-equivalent validation.

Usage:
  run_groimp_tests.sh [test type] [validation scenario] [number of steps] [model options file]
  Note: provide "" to use a parameter's default value.

Parameters:
  test type:
    Simulation test type (default: XrunTests).
  validation scenario:
    Scenario name for validation (default: default).
  number of steps:
    Optional integer number of simulation steps. Decimal values are truncated.
  model options file:
    Optional override for FILE_NAME_MODEL_OPTIONS. GitHub-equivalent validation
    does not pass this; scenario YAML should drive model-options selection.

Project entry:
  Default project entry: Scripts/project.gs
  Use PROJECT_ENTRY_HOST=.../Scripts/Scripts.gsz only for archive/package validation.

Examples:
  bash tests/validation/run_groimp_tests.sh XrunValidationTests stormTest
  PROJECT_ENTRY_HOST="$PWD/Scripts/Scripts.gsz" bash tests/validation/run_groimp_tests.sh XrunValidationTests default
###############################################################
EOF
}

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
    usage
    exit 0
fi

TEST_TYPE="${1:-XrunTests}"
VALIDATION_SCENARIO="${2:-default}"
NUM_STEPS="${3:-}"
MODEL_OPTIONS="${4:-}"
NUM_STEPS="${NUM_STEPS%.*}"

echo "Running validation test:"
echo "Repo Path: ${REPO_PATH}"
echo "Test Type: ${TEST_TYPE}"
echo "Validation Scenario: ${VALIDATION_SCENARIO}"
[[ -n "${NUM_STEPS}" ]] && echo "Number of Steps: ${NUM_STEPS}"
[[ -n "${MODEL_OPTIONS}" ]] && echo "Model Options File: ${MODEL_OPTIONS}"
echo "Apptainer Image: ${APPTAINER_IMAGE_PATH}"
echo "Project Entry Host: ${PROJECT_ENTRY_HOST}"
echo "Project Entry Ctr: ${PROJECT_ENTRY_CONTAINER}"

[[ -f "${PROJECT_ENTRY_HOST}" ]] || {
    echo "Project entry not found: ${PROJECT_ENTRY_HOST}" >&2
    exit 1
}
[[ -f "${APPTAINER_IMAGE_PATH}" ]] || {
    echo "Apptainer image not found: ${APPTAINER_IMAGE_PATH}" >&2
    exit 1
}
command -v apptainer >/dev/null 2>&1 || {
    echo "apptainer command not found. Install Apptainer or use unitTest.sh for direct-Java smoke tests." >&2
    exit 1
}

if [[ -n "${GROIMP_RUNTIME_HOME:-}" ]]; then
    RUNTIME_HOME="${GROIMP_RUNTIME_HOME}"
    RUNTIME_HOME_IS_TEMP=0
else
    RUNTIME_HOME="${REPO_PATH}/tmp/groimp_home_${USER:-user}_$$"
    RUNTIME_HOME_IS_TEMP=1
fi
mkdir -p "${RUNTIME_HOME}/.java/.userPrefs" "${RUNTIME_HOME}/.grogra.de-platform/log"

APPTAINER_RUNTIME_BINDS=()
case "${RUNTIME_HOME}" in
    "${REPO_PATH}"/*)
        RUNTIME_HOME_CONTAINER="/var/model/${RUNTIME_HOME#${REPO_PATH}/}"
        ;;
    *)
        RUNTIME_HOME_CONTAINER="${RUNTIME_HOME}"
        APPTAINER_RUNTIME_BINDS+=(--bind "${RUNTIME_HOME}:${RUNTIME_HOME}")
        ;;
esac

cleanup_runtime_home() {
    if [[ "${RUNTIME_HOME_IS_TEMP}" == "1" && "${GROIMP_KEEP_RUNTIME_HOME:-0}" != "1" ]]; then
        rm -rf "${RUNTIME_HOME}"
    else
        echo "Keeping GroIMP runtime home: ${RUNTIME_HOME}"
    fi
}
trap cleanup_runtime_home EXIT

echo "Runtime HOME: ${RUNTIME_HOME_CONTAINER}"

GROIMP_RUN_CMD=(
    apptainer exec
    --bind "${REPO_PATH}:/var/model"
    "${APPTAINER_RUNTIME_BINDS[@]}"
    "${APPTAINER_IMAGE_PATH}"
    java
    -Djava.awt.headless=true
    "-Duser.home=${RUNTIME_HOME_CONTAINER}"
    "-Djava.util.prefs.userRoot=${RUNTIME_HOME_CONTAINER}/.java/.userPrefs"
    -XX:+UseContainerSupport
    -Xms2g
    -Xmx10g
    -Xss1m
    -XX:+UseSerialGC
    -XX:+UnlockDiagnosticVMOptions
    -XX:-TieredCompilation
    -XX:+AlwaysPreTouch
    -noverify
    -jar "${GROIMP_DIR}/core.jar"
    --headless
    "-${TEST_TYPE}"
    -XmodelPath=/var/model/
    "-XvalidationTestScenario=${VALIDATION_SCENARIO}"
)

if [[ -n "${NUM_STEPS:-}" ]]; then
    GROIMP_RUN_CMD+=("-XrunEndSteps=${NUM_STEPS}")
fi

if [[ -n "${MODEL_OPTIONS:-}" ]]; then
    GROIMP_RUN_CMD+=("-XmodelOptions=${MODEL_OPTIONS}")
fi

GROIMP_RUN_CMD+=("${PROJECT_ENTRY_CONTAINER}")

echo "Starting Simulation..."
printf 'Running command:'
printf ' %q' "${GROIMP_RUN_CMD[@]}"
echo

"${GROIMP_RUN_CMD[@]}"

EXIT_CODE=$?

if [[ "${EXIT_CODE}" -eq 0 ]]; then
    echo "Test completed successfully."
else
    echo "Test failed with exit code ${EXIT_CODE}"
    exit "${EXIT_CODE}"
fi
