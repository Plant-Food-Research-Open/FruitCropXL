#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

LOG_DIR="${REPO_ROOT}/tests/validation"
UNIT_LOG="${LOG_DIR}/finalise_source_unit.log"
ACCEPTANCE_LOG="${LOG_DIR}/default.log"
ARCHIVE_LOG="${REPO_ROOT}/Model_output/logs/groimp_archive_default.log"
MANIFEST_COMMAND="${REPO_ROOT}/bash_scripts/gsz_source_manifest.sh"
STAGE_COMMAND="${REPO_ROOT}/bash_scripts/stage_gsz_sources.sh"
ARCHIVE="${REPO_ROOT}/Scripts/Scripts.gsz"
DEFAULT_OUTPUT="${REPO_ROOT}/Model_output/default"
SKIP_ACCEPTANCE="${FINALISE_SKIP_LOCAL_ACCEPTANCE:-0}"
METADATA_SOURCE="${FINALISE_GSZ_METADATA_SOURCE:-head}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  bash tests/gsz_test/finalise_repository.sh \
    [--metadata-source=head|worktree]

The default HEAD mode ignores local and staged GroIMP project-file changes.
Use worktree mode only when intentional project.gs, graph*.xml,
META-INF/MANIFEST.MF, or workbench.options changes will be committed together
with the generated Scripts.gsz.
EOF
}

for ARG in "$@"; do
  case "${ARG}" in
    --metadata-source=head)
      METADATA_SOURCE="head"
      ;;
    --metadata-source=worktree)
      METADATA_SOURCE="worktree"
      ;;
    --metadata-source=*)
      fail "Unsupported metadata source: ${ARG#*=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

case "${METADATA_SOURCE}" in
  head|worktree)
    ;;
  *)
    fail "FINALISE_GSZ_METADATA_SOURCE must be 'head' or 'worktree': ${METADATA_SOURCE}"
    ;;
esac

source_tree_digest() (
  local digest_dir manifest_path stage_dir
  digest_dir="$(mktemp -d "${TMPDIR:-/tmp}/fruitcropxl-gsz-digest.XXXXXX")"
  trap 'find "${digest_dir}" -mindepth 1 -delete; rmdir "${digest_dir}"' EXIT
  manifest_path="${digest_dir}/manifest.txt"
  stage_dir="${digest_dir}/stage"

  GSZ_METADATA_SOURCE="${METADATA_SOURCE}" \
    "${MANIFEST_COMMAND}" > "${manifest_path}"
  "${STAGE_COMMAND}" "--metadata-source=${METADATA_SOURCE}" "${stage_dir}" "${manifest_path}"
  (
    cd "${stage_dir}"
    while IFS= read -r ENTRY; do
      sha256sum "${ENTRY}"
    done < "${manifest_path}"
  ) \
    | sha256sum \
    | awk '{print $1}'
)

latest_default_output_mtime() {
  if [[ -d "${DEFAULT_OUTPUT}" ]]; then
    find "${DEFAULT_OUTPUT}" -type f -printf '%T@\n' \
      | LC_ALL=C sort -n \
      | tail -n 1
  fi
}

run_logged() {
  local label="$1"
  local log="$2"
  shift 2

  echo
  echo "==> ${label}"
  echo "    log: ${log}"
  set +e
  "$@" 2>&1 | tee "${log}"
  local code=${PIPESTATUS[0]}
  set -e
  echo "    exit code: ${code}"
  [[ "${code}" -eq 0 ]] || fail "${label} failed (see ${log})"
}

[[ "${SKIP_ACCEPTANCE}" == "0" || "${SKIP_ACCEPTANCE}" == "1" ]] \
  || fail "FINALISE_SKIP_LOCAL_ACCEPTANCE must be 0 or 1"
[[ -x "${MANIFEST_COMMAND}" ]] || fail "Manifest command is not executable"
[[ -x "${STAGE_COMMAND}" ]] || fail "Source staging command is not executable"

mkdir -p "${LOG_DIR}" "${REPO_ROOT}/Model_output/logs"
OUTPUT_MTIME_BEFORE="$(latest_default_output_mtime)"

echo "FruitCropXL final repository validation"
echo "Repository: ${REPO_ROOT}"
echo "GroIMP project-file source: ${METADATA_SOURCE}"
echo "This command validates and packages files; it does not create a Git commit."

echo
echo "=== Stage A: source validation ==="
run_logged \
  "Portable source unit/smoke test" \
  "${UNIT_LOG}" \
  bash tests/smoke_test/unitTest.sh
STRICT_COMPILE_SCAN=1 \
  bash tests/diagnosis/grep_compile_errors.sh "${UNIT_LOG}"

if [[ "${SKIP_ACCEPTANCE}" == "0" ]]; then
  run_logged \
    "Default source acceptance scenario" \
    "${ACCEPTANCE_LOG}" \
    bash tests/validation/run_multiple_scenarios.sh default
  STRICT_COMPILE_SCAN=1 \
    bash tests/diagnosis/grep_compile_errors.sh "${ACCEPTANCE_LOG}"
else
  echo "NOTICE: Local Apptainer acceptance explicitly skipped by FINALISE_SKIP_LOCAL_ACCEPTANCE=1."
fi

echo
echo "=== Stage B: deterministic package ==="
bash tests/gsz_test/test_gsz_metadata_source.sh
bash tests/gsz_test/check_gsz_reproducibility.sh "--metadata-source=${METADATA_SOURCE}"
SOURCE_DIGEST_BEFORE_DOCS="$(source_tree_digest)"

echo
echo "=== Stage C: archive validation ==="
bash tests/gsz_test/validate_gsz_structure.sh "--metadata-source=${METADATA_SOURCE}" "${ARCHIVE}"
ARCHIVE_RUNNER=direct \
GSZ_METADATA_SOURCE="${METADATA_SOURCE}" \
  bash tests/gsz_test/run_archive_test.sh default 2 model.options.default.json
STRICT_COMPILE_SCAN=1 \
  bash tests/diagnosis/grep_compile_errors.sh "${ARCHIVE_LOG}"

echo
echo "=== Stage D: documentation consistency ==="
bash tests/gsz_test/check_gsz_documentation.sh
bash tests/diagnosis/check_fruit_module_class_names.sh

echo
echo "=== Stage E: final regression ==="
SOURCE_DIGEST_AFTER_DOCS="$(source_tree_digest)"
if [[ "${SOURCE_DIGEST_BEFORE_DOCS}" != "${SOURCE_DIGEST_AFTER_DOCS}" ]]; then
  echo "Scripts/ changed during documentation checks; rebuilding the archive."
  bash bash_scripts/zip_groimp.sh "--metadata-source=${METADATA_SOURCE}"
else
  echo "Scripts/ did not change during documentation checks; verifying the existing archive."
fi

bash tests/gsz_test/validate_gsz_structure.sh "--metadata-source=${METADATA_SOURCE}" "${ARCHIVE}"
ARCHIVE_RUNNER=direct \
GSZ_METADATA_SOURCE="${METADATA_SOURCE}" \
  bash tests/gsz_test/run_archive_test.sh default 2 model.options.default.json
STRICT_COMPILE_SCAN=1 \
  bash tests/diagnosis/grep_compile_errors.sh "${ARCHIVE_LOG}"
bash tests/gsz_test/check_gsz_documentation.sh
bash tests/diagnosis/check_fruit_module_class_names.sh
git diff --check

if find Scripts -maxdepth 1 -type d -name '.gsz-package.*' -print -quit | rg -q .; then
  fail "Temporary .gsz-package directory remains under Scripts/"
fi

OUTPUT_MTIME_AFTER="$(latest_default_output_mtime)"
if [[ -n "${OUTPUT_MTIME_AFTER}" && "${OUTPUT_MTIME_AFTER}" != "${OUTPUT_MTIME_BEFORE}" ]]; then
  DEFAULT_OUTPUT_UPDATED="yes"
else
  DEFAULT_OUTPUT_UPDATED="no"
fi

echo
echo "=== Final summary ==="
echo "Stage A source unit       : passed (${UNIT_LOG})"
if [[ "${SKIP_ACCEPTANCE}" == "0" ]]; then
  echo "Stage A default acceptance: passed (${ACCEPTANCE_LOG})"
else
  echo "Stage A default acceptance: explicitly skipped"
fi
echo "Stage B package/reproduce : passed"
echo "Stage C archive validation: passed (${ARCHIVE_LOG})"
echo "Stage D documentation     : passed"
echo "Stage E final regression  : passed"
echo "Project-file source       : ${METADATA_SOURCE}"
echo "Generated archive         : ${ARCHIVE}"
echo "Archive SHA-256            : $(sha256sum "${ARCHIVE}" | awk '{print $1}')"
echo "Model_output/default update: ${DEFAULT_OUTPUT_UPDATED}"
echo
echo "Working tree (review every entry before the intentional final commit):"
git status --short

HIDDEN_FILES=()
LOCAL_PROJECT_DIFFERENCES=()
while IFS= read -r PROJECT_FILE; do
  [[ -n "${PROJECT_FILE}" ]] || continue

  if git ls-files -v -- "${PROJECT_FILE}" | rg -q '^[a-z] '; then
    HIDDEN_FILES+=("${PROJECT_FILE}")
  fi

  HEAD_BLOB="$(git rev-parse "HEAD:${PROJECT_FILE}" 2>/dev/null || true)"
  if [[ -f "${PROJECT_FILE}" ]]; then
    WORKTREE_BLOB="$(git hash-object --no-filters -- "${PROJECT_FILE}")"
  else
    WORKTREE_BLOB=""
  fi
  if [[ "${HEAD_BLOB}" != "${WORKTREE_BLOB}" ]]; then
    LOCAL_PROJECT_DIFFERENCES+=("${PROJECT_FILE}")
  fi
done < <(
  {
    printf '%s\n' \
      "Scripts/project.gs" \
      "Scripts/graph.xml" \
      "Scripts/META-INF/MANIFEST.MF" \
      "Scripts/workbench.options" \
      "Scripts/Scripts.gsz"
    git ls-tree -r --name-only HEAD -- Scripts/ \
      | rg '^Scripts/graph\..*\.xml$' || true
    find Scripts -maxdepth 1 -type f -name 'graph.*.xml' -printf '%p\n'
  } | LC_ALL=C sort -u
)

if ((${#LOCAL_PROJECT_DIFFERENCES[@]} > 0)); then
  echo
  if [[ "${METADATA_SOURCE}" == "head" ]]; then
    echo "Local GroIMP project-file differences ignored by HEAD-mode packaging:"
  else
    echo "Intentional GroIMP project-file differences that must accompany Scripts.gsz:"
  fi
  printf '  %s\n' "${LOCAL_PROJECT_DIFFERENCES[@]}"
fi

if ((${#HIDDEN_FILES[@]} > 0)); then
  echo
  echo "NOTICE: local Git index flags still hide tracked project files:"
  printf '  %s\n' "${HIDDEN_FILES[@]}"
  echo "Clear the clone-local flags before reviewing or staging the final commit:"
  printf '  git update-index --no-assume-unchanged --no-skip-worktree'
  printf ' %q' "${HIDDEN_FILES[@]}"
  echo
fi
