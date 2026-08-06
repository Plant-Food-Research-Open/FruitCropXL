#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 \
  && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

SCRIPTS_DIR="${GSZ_SOURCE_DIR:-${REPO_ROOT}/Scripts}"
METADATA_SOURCE="${GSZ_METADATA_SOURCE:-head}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ -d "${SCRIPTS_DIR}" ]] || fail "Scripts source directory not found: ${SCRIPTS_DIR}"
case "${METADATA_SOURCE}" in
  head|worktree)
    ;;
  *)
    fail "GSZ_METADATA_SOURCE must be 'head' or 'worktree': ${METADATA_SOURCE}"
    ;;
esac

is_managed_project_file() {
  case "$1" in
    project.gs|graph.xml|graph.*.xml|META-INF/MANIFEST.MF|workbench.options)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

REQUIRED_PROJECT_FILES=(
  "project.gs"
  "graph.xml"
  "META-INF/MANIFEST.MF"
  "workbench.options"
)

if [[ "${METADATA_SOURCE}" == "head" ]]; then
  git -C "${REPO_ROOT}" rev-parse --verify HEAD >/dev/null 2>&1 \
    || fail "HEAD is required for committed GroIMP project metadata"
  for ENTRY in "${REQUIRED_PROJECT_FILES[@]}"; do
    git -C "${REPO_ROOT}" cat-file -e "HEAD:Scripts/${ENTRY}" 2>/dev/null \
      || fail "Required GroIMP project file is not tracked in HEAD: Scripts/${ENTRY}"
  done
else
  for ENTRY in "${REQUIRED_PROJECT_FILES[@]}"; do
    [[ -f "${SCRIPTS_DIR}/${ENTRY}" ]] \
      || fail "Required GroIMP project file is missing from the working tree: ${ENTRY}"
  done
fi

SYMLINK="$(find "${SCRIPTS_DIR}" -type l -print -quit)"
[[ -z "${SYMLINK}" ]] \
  || fail "Symlinks are not supported in Scripts.gsz: ${SYMLINK#${SCRIPTS_DIR}/}"

{
  (
  cd "${SCRIPTS_DIR}"
  find . -type f -print0 \
    | while IFS= read -r -d '' SOURCE_PATH; do
        ENTRY="${SOURCE_PATH#./}"

        case "${ENTRY}" in
          /*|../*|*/../*|*/..|*\\*)
            fail "Unsafe source path cannot be packaged: ${ENTRY}"
            ;;
        esac

        # Repository instructions and local/editor/build artefacts are not
        # GroIMP project content. All other regular files are included so new
        # source modules and resources cannot be silently omitted.
        case "/${ENTRY}/" in
          */.git/*|*/.github/*|*/.idea/*|*/.vscode/*|*/__pycache__/*|\
          */.pytest_cache/*|*/.mypy_cache/*|*/.cache/*|\
          */.gsz-package.*/*|*/logs/*|*/tmp/*|*/temp/*)
            continue
            ;;
        esac

        BASENAME="${ENTRY##*/}"
        case "${BASENAME}" in
          .gitignore|.gitattributes|.DS_Store|AGENTS.md|\
          Scripts.gsz|Scripts.zip|*.gsz|*.gsz~|*.zip|*.zip~|\
          config.properties.txt|*.log|*.tmp|*.temp|*.class|*.pyc|*.pyo|\
          *.swp|*.swo|*.bak|*.orig|*~|.#*|\#*\#|.nfs*)
            continue
            ;;
        esac

        [[ "${ENTRY}" != *$'\n'* && "${ENTRY}" != *$'\r'* ]] \
          || fail "Newline characters are not supported in archive paths: ${ENTRY}"

        if [[ "${METADATA_SOURCE}" == "head" ]] \
          && is_managed_project_file "${ENTRY}"; then
          continue
        fi
        printf '%s\n' "${ENTRY}"
      done \
  )

  if [[ "${METADATA_SOURCE}" == "head" ]]; then
    git -C "${REPO_ROOT}" ls-tree -r -z --name-only HEAD -- Scripts/ \
      | while IFS= read -r -d '' TRACKED_PATH; do
          ENTRY="${TRACKED_PATH#Scripts/}"
          if is_managed_project_file "${ENTRY}"; then
            [[ "${ENTRY}" != *$'\n'* && "${ENTRY}" != *$'\r'* ]] \
              || fail "Newline characters are not supported in archive paths: ${ENTRY}"
            printf '%s\n' "${ENTRY}"
          fi
        done
  fi
} | LC_ALL=C sort -u
