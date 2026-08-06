#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PACKAGER="${REPO_ROOT}/bash_scripts/zip_groimp.sh"
TEMP_ROOT=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

cleanup() {
  if [[ -n "${TEMP_ROOT}" && -d "${TEMP_ROOT}" ]]; then
    find "${TEMP_ROOT}" -mindepth 1 -delete
    rmdir "${TEMP_ROOT}"
  fi
}
trap cleanup EXIT HUP INT TERM

command -v unzip >/dev/null 2>&1 || fail "unzip is required"
[[ -x "${PACKAGER}" ]] || fail "Packager is not executable: ${PACKAGER}"

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/fruitcropxl-gsz-metadata.XXXXXX")"
TEMP_SCRIPTS="${TEMP_ROOT}/Scripts"
TEMP_ARCHIVE="${TEMP_SCRIPTS}/Scripts.gsz"
UNUSED_INDEX="${TEMP_ROOT}/index-is-deliberately-unused"
mkdir -p "${TEMP_SCRIPTS}"
cp -a "${REPO_ROOT}/Scripts/." "${TEMP_SCRIPTS}/"

HEAD_PROJECT_BLOB="$(git -C "${REPO_ROOT}" rev-parse HEAD:Scripts/project.gs)"
printf '\n// deliberate temporary local-only metadata change\n' >> "${TEMP_SCRIPTS}/project.gs"
WORKTREE_PROJECT_BLOB="$(git hash-object --no-filters -- "${TEMP_SCRIPTS}/project.gs")"
[[ "${HEAD_PROJECT_BLOB}" != "${WORKTREE_PROJECT_BLOB}" ]] \
  || fail "Temporary project.gs mutation did not change its blob"

# A nonexistent alternate index proves that normal packaging does not read
# staged/index content. The local project.gs mutation must also be ignored.
GIT_INDEX_FILE="${UNUSED_INDEX}" \
GSZ_SOURCE_DIR="${TEMP_SCRIPTS}" \
GSZ_ARCHIVE_PATH="${TEMP_ARCHIVE}" \
  "${PACKAGER}" --metadata-source=head

ARCHIVE_PROJECT_BLOB="$(unzip -p "${TEMP_ARCHIVE}" project.gs | git hash-object --stdin)"
[[ "${ARCHIVE_PROJECT_BLOB}" == "${HEAD_PROJECT_BLOB}" ]] \
  || fail "HEAD-mode archive did not contain committed project.gs"
[[ "${ARCHIVE_PROJECT_BLOB}" != "${WORKTREE_PROJECT_BLOB}" ]] \
  || fail "HEAD-mode archive leaked the local project.gs change"

GSZ_SOURCE_DIR="${TEMP_SCRIPTS}" \
GSZ_ARCHIVE_PATH="${TEMP_ARCHIVE}" \
  "${PACKAGER}" --metadata-source=worktree

ARCHIVE_PROJECT_BLOB="$(unzip -p "${TEMP_ARCHIVE}" project.gs | git hash-object --stdin)"
[[ "${ARCHIVE_PROJECT_BLOB}" == "${WORKTREE_PROJECT_BLOB}" ]] \
  || fail "Worktree-mode archive did not contain the intentional local project.gs"

VALID_SHA="$(sha256sum "${TEMP_ARCHIVE}" | awk '{print $1}')"
mv "${TEMP_SCRIPTS}/project.gs" "${TEMP_SCRIPTS}/project.gs.missing"

set +e
GSZ_SOURCE_DIR="${TEMP_SCRIPTS}" \
GSZ_ARCHIVE_PATH="${TEMP_ARCHIVE}" \
  "${PACKAGER}" --metadata-source=worktree
MISSING_CODE=$?
set -e

[[ "${MISSING_CODE}" -ne 0 ]] \
  || fail "Worktree packaging unexpectedly accepted a missing project.gs"
AFTER_FAILURE_SHA="$(sha256sum "${TEMP_ARCHIVE}" | awk '{print $1}')"
[[ "${AFTER_FAILURE_SHA}" == "${VALID_SHA}" ]] \
  || fail "Failed worktree packaging replaced the last valid archive"

echo "Scripts.gsz metadata-source regression passed:"
echo "  default HEAD mode ignores local and index state"
echo "  explicit worktree mode includes intentional project metadata"
echo "  missing required worktree metadata fails without replacing the archive"
