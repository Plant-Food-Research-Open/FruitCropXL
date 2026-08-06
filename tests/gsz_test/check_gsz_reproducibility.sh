#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

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

command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is required"
command -v cmp >/dev/null 2>&1 || fail "cmp is required"
[[ -x "${PACKAGER}" ]] || fail "Packager is not executable: ${PACKAGER}"

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/fruitcropxl-gsz-reproducibility.XXXXXX")"
FIRST_DIR="${TEMP_ROOT}/first"
SECOND_DIR="${TEMP_ROOT}/second"
FIRST_ARCHIVE="${FIRST_DIR}/Scripts.gsz"
SECOND_ARCHIVE="${SECOND_DIR}/Scripts.gsz"
mkdir -p "${FIRST_DIR}" "${SECOND_DIR}"

# Build twice into temporary paths. This test verifies deterministic packaging
# without rewriting the tracked Scripts/Scripts.gsz. The following structural
# validation step is responsible for checking the committed archive contents.
GSZ_ARCHIVE_PATH="${FIRST_ARCHIVE}" "${PACKAGER}" "$@"
GSZ_ARCHIVE_PATH="${SECOND_ARCHIVE}" "${PACKAGER}" "$@"

FIRST_SHA="$(sha256sum "${FIRST_ARCHIVE}" | awk '{print $1}')"
SECOND_SHA="$(sha256sum "${SECOND_ARCHIVE}" | awk '{print $1}')"

if ! cmp -s -- "${FIRST_ARCHIVE}" "${SECOND_ARCHIVE}"; then
  echo "ERROR: unchanged Scripts.gsz builds are not byte-identical" >&2
  echo "  first : ${FIRST_SHA}" >&2
  echo "  second: ${SECOND_SHA}" >&2
  exit 1
fi

echo "Scripts.gsz reproducibility check passed: ${FIRST_SHA}"
echo "Tracked Scripts/Scripts.gsz was not modified by this check."
