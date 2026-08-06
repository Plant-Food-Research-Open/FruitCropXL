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
ARCHIVE_PATH="${GSZ_ARCHIVE_PATH:-${SCRIPTS_DIR}/Scripts.gsz}"
MANIFEST_COMMAND="${REPO_ROOT}/bash_scripts/gsz_source_manifest.sh"
STAGE_COMMAND="${REPO_ROOT}/bash_scripts/stage_gsz_sources.sh"
VALIDATOR="${REPO_ROOT}/tests/gsz_test/validate_gsz_structure.sh"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-315532800}"
METADATA_SOURCE="${GSZ_METADATA_SOURCE:-head}"
BUILD_DIR=""

usage() {
  cat <<'EOF'
Usage:
  bash bash_scripts/zip_groimp.sh [--metadata-source=head|worktree]

Build Scripts/Scripts.gsz deterministically from the complete intended
Scripts/ source manifest. Legacy arguments 0 and 1 are accepted but no longer
select a partial update: every invocation performs a clean full rebuild.

GroIMP-managed project files (project.gs, graph*.xml, META-INF/MANIFEST.MF,
and workbench.options) are read from HEAD by default. Local and staged changes
to those generated files are deliberately excluded.

Use --metadata-source=worktree only when the local GroIMP project files are an
intentional update that will be committed together with Scripts.gsz.

Reproducible timestamp:
  SOURCE_DATE_EPOCH defaults to 315532800 (1980-01-01 00:00:00 UTC), the
  earliest portable ZIP timestamp.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

cleanup() {
  if [[ -n "${BUILD_DIR}" && -d "${BUILD_DIR}" ]]; then
    find "${BUILD_DIR}" -mindepth 1 -delete
    rmdir "${BUILD_DIR}"
  fi
}
trap cleanup EXIT HUP INT TERM

for ARG in "$@"; do
  case "${ARG}" in
    -h|--help)
      usage
      exit 0
      ;;
    --metadata-source=head)
      METADATA_SOURCE="head"
      ;;
    --metadata-source=worktree)
      METADATA_SOURCE="worktree"
      ;;
    --metadata-source=*)
      fail "Unsupported metadata source: ${ARG#*=}"
      ;;
    0|1)
      echo "NOTICE: legacy partial-update argument '${ARG}' is ignored; performing a full rebuild."
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
    fail "GSZ_METADATA_SOURCE must be 'head' or 'worktree': ${METADATA_SOURCE}"
    ;;
esac

if [[ ! -d "$(dirname "${ARCHIVE_PATH}")" ]]; then
  fail "Archive parent directory does not exist: $(dirname "${ARCHIVE_PATH}")"
fi

command -v python3 >/dev/null 2>&1 || fail "python3 is required"
[[ -x "${MANIFEST_COMMAND}" ]] || fail "Manifest command is not executable: ${MANIFEST_COMMAND}"
[[ -x "${STAGE_COMMAND}" ]] || fail "Source staging command is not executable: ${STAGE_COMMAND}"
[[ -x "${VALIDATOR}" ]] || fail "Archive validator is not executable: ${VALIDATOR}"
[[ "${SOURCE_DATE_EPOCH}" =~ ^[0-9]+$ ]] \
  || fail "SOURCE_DATE_EPOCH must be a non-negative integer"
((SOURCE_DATE_EPOCH >= 315532800)) \
  || fail "SOURCE_DATE_EPOCH predates the ZIP minimum (1980-01-01 UTC)"

BUILD_DIR="$(mktemp -d "$(dirname "${ARCHIVE_PATH}")/.gsz-package.XXXXXX")"
STAGE_DIR="${BUILD_DIR}/stage"
MANIFEST_PATH="${BUILD_DIR}/manifest.txt"
TEMP_ARCHIVE="${BUILD_DIR}/Scripts.gsz"
mkdir -p "${STAGE_DIR}"

GSZ_SOURCE_DIR="${SCRIPTS_DIR}" \
GSZ_METADATA_SOURCE="${METADATA_SOURCE}" \
  "${MANIFEST_COMMAND}" > "${MANIFEST_PATH}"
[[ -s "${MANIFEST_PATH}" ]] || fail "The intended Scripts.gsz manifest is empty"

echo "Packaging Scripts.gsz from $(wc -l < "${MANIFEST_PATH}") sorted source entries..."
echo "GroIMP project-file source: ${METADATA_SOURCE}"
GSZ_SOURCE_DIR="${SCRIPTS_DIR}" \
  "${STAGE_COMMAND}" "--metadata-source=${METADATA_SOURCE}" "${STAGE_DIR}" "${MANIFEST_PATH}"

python3 - "${STAGE_DIR}" "${MANIFEST_PATH}" "${TEMP_ARCHIVE}" "${SOURCE_DATE_EPOCH}" <<'PY'
import datetime
import pathlib
import sys
import zipfile

stage_dir = pathlib.Path(sys.argv[1])
manifest_path = pathlib.Path(sys.argv[2])
archive_path = pathlib.Path(sys.argv[3])
epoch = int(sys.argv[4])

timestamp = datetime.datetime.fromtimestamp(epoch, datetime.timezone.utc)
if timestamp.year > 2107:
    raise SystemExit("SOURCE_DATE_EPOCH exceeds the ZIP timestamp range")
timestamp = timestamp.replace(second=timestamp.second - timestamp.second % 2)
zip_timestamp = (
    timestamp.year,
    timestamp.month,
    timestamp.day,
    timestamp.hour,
    timestamp.minute,
    timestamp.second,
)

entries = manifest_path.read_text(encoding="utf-8").splitlines()
if entries != sorted(entries) or len(entries) != len(set(entries)):
    raise SystemExit("Source manifest must be sorted and contain unique entries")

with zipfile.ZipFile(archive_path, mode="x", compression=zipfile.ZIP_STORED) as archive:
    archive.comment = b""
    for entry in entries:
        source_path = stage_dir / entry
        info = zipfile.ZipInfo(entry, date_time=zip_timestamp)
        info.create_system = 3
        info.compress_type = zipfile.ZIP_STORED
        info.external_attr = (0o100644 & 0xFFFF) << 16
        info.extra = b""
        info.comment = b""
        archive.writestr(info, source_path.read_bytes())
PY

# Test-only fault injection used by test_gsz_packaging_failures.sh. It occurs
# before validation and therefore must never be able to replace the valid file.
if [[ "${GSZ_TEST_CORRUPT_TEMP_ARCHIVE:-0}" == "1" ]]; then
  printf 'deliberately corrupted archive\n' > "${TEMP_ARCHIVE}"
fi

GSZ_SOURCE_DIR="${SCRIPTS_DIR}" \
  "${VALIDATOR}" "--metadata-source=${METADATA_SOURCE}" "${TEMP_ARCHIVE}"

# Recreate the canonical source view immediately before replacement. If a
# working-tree source or selected GroIMP project file changed during packaging,
# fail rather than publishing a mixed snapshot.
VERIFY_STAGE_DIR="${BUILD_DIR}/verify-stage"
mkdir -p "${VERIFY_STAGE_DIR}"
GSZ_SOURCE_DIR="${SCRIPTS_DIR}" \
  "${STAGE_COMMAND}" "--metadata-source=${METADATA_SOURCE}" "${VERIFY_STAGE_DIR}" "${MANIFEST_PATH}"
while IFS= read -r ENTRY; do
  cmp -- "${STAGE_DIR}/${ENTRY}" "${VERIFY_STAGE_DIR}/${ENTRY}" >/dev/null \
    || fail "Canonical package source changed while packaging: ${ENTRY}"
done < "${MANIFEST_PATH}"

chmod 0644 "${TEMP_ARCHIVE}"
mv -f -- "${TEMP_ARCHIVE}" "${ARCHIVE_PATH}"

echo "Created and validated: ${ARCHIVE_PATH}"
echo "SHA-256: $(sha256sum "${ARCHIVE_PATH}" | awk '{print $1}')"
