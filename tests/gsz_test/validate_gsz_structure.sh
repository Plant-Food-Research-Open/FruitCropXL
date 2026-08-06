#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v git >/dev/null 2>&1 \
  && git -C "${SCRIPT_DIR}" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi

ARCHIVE_PATH="${REPO_ROOT}/Scripts/Scripts.gsz"
MANIFEST_COMMAND="${REPO_ROOT}/bash_scripts/gsz_source_manifest.sh"
STAGE_COMMAND="${REPO_ROOT}/bash_scripts/stage_gsz_sources.sh"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-315532800}"
METADATA_SOURCE="${GSZ_METADATA_SOURCE:-head}"
TEMP_DIR=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

cleanup() {
  if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    find "${TEMP_DIR}" -mindepth 1 -delete
    rmdir "${TEMP_DIR}"
  fi
}
trap cleanup EXIT HUP INT TERM

POSITIONAL=()
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
      cat <<'EOF'
Usage:
  bash tests/gsz_test/validate_gsz_structure.sh \
    [--metadata-source=head|worktree] [ARCHIVE]
EOF
      exit 0
      ;;
    *)
      POSITIONAL+=("${ARG}")
      ;;
  esac
done

if ((${#POSITIONAL[@]} > 1)); then
  fail "Only one archive path may be supplied"
fi
if ((${#POSITIONAL[@]} == 1)); then
  ARCHIVE_PATH="${POSITIONAL[0]}"
fi
case "${METADATA_SOURCE}" in
  head|worktree)
    ;;
  *)
    fail "GSZ_METADATA_SOURCE must be 'head' or 'worktree': ${METADATA_SOURCE}"
    ;;
esac

command -v unzip >/dev/null 2>&1 || fail "unzip is required"
command -v zipinfo >/dev/null 2>&1 || fail "zipinfo is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"
[[ -x "${MANIFEST_COMMAND}" ]] || fail "Manifest command is not executable: ${MANIFEST_COMMAND}"
[[ -x "${STAGE_COMMAND}" ]] || fail "Source staging command is not executable: ${STAGE_COMMAND}"
[[ -f "${ARCHIVE_PATH}" ]] || fail "Archive does not exist: ${ARCHIVE_PATH}"
[[ -s "${ARCHIVE_PATH}" ]] || fail "Archive is empty: ${ARCHIVE_PATH}"

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fruitcropxl-gsz-validate.XXXXXX")"
EXPECTED_MANIFEST="${TEMP_DIR}/expected.txt"
ARCHIVE_MANIFEST="${TEMP_DIR}/archive.txt"
EXTRACT_DIR="${TEMP_DIR}/extracted"
EXPECTED_DIR="${TEMP_DIR}/expected"

GSZ_METADATA_SOURCE="${METADATA_SOURCE}" \
  "${MANIFEST_COMMAND}" > "${EXPECTED_MANIFEST}"
"${STAGE_COMMAND}" "--metadata-source=${METADATA_SOURCE}" "${EXPECTED_DIR}" "${EXPECTED_MANIFEST}"
zipinfo -1 "${ARCHIVE_PATH}" > "${ARCHIVE_MANIFEST}" \
  || fail "Archive entries cannot be listed: ${ARCHIVE_PATH}"
[[ -s "${ARCHIVE_MANIFEST}" ]] || fail "Archive entry list is empty"

unzip -tqq "${ARCHIVE_PATH}" >/dev/null \
  || fail "ZIP integrity test failed: ${ARCHIVE_PATH}"

python3 - "${ARCHIVE_PATH}" "${EXPECTED_MANIFEST}" "${SOURCE_DATE_EPOCH}" <<'PY'
import datetime
import pathlib
import posixpath
import sys
import zipfile

archive_path = pathlib.Path(sys.argv[1])
expected_path = pathlib.Path(sys.argv[2])
epoch = int(sys.argv[3])
expected = expected_path.read_text(encoding="utf-8").splitlines()

timestamp = datetime.datetime.fromtimestamp(epoch, datetime.timezone.utc)
timestamp = timestamp.replace(second=timestamp.second - timestamp.second % 2)
expected_timestamp = (
    timestamp.year,
    timestamp.month,
    timestamp.day,
    timestamp.hour,
    timestamp.minute,
    timestamp.second,
)

required = {
    "META-INF/MANIFEST.MF",
    "project.gs",
    "graph.xml",
    "workbench.options",
    "main/main.rgg",
    "config/globalParameters.rgg",
    "utils/BasicMinervaHelper.java",
    "images/grapevine-bark.png",
}

with zipfile.ZipFile(archive_path) as archive:
    infos = archive.infolist()
    names = [info.filename for info in infos]

    if archive.comment:
        raise SystemExit("Archive comment must be empty")
    if not names:
        raise SystemExit("Archive contains no entries")
    if len(names) != len(set(names)):
        duplicates = sorted({name for name in names if names.count(name) > 1})
        raise SystemExit("Duplicate archive entries: " + ", ".join(duplicates))
    if names != expected:
        raise SystemExit("Archive entry order or manifest differs from the intended sorted source manifest")

    missing = sorted(required.difference(names))
    if missing:
        raise SystemExit("Required GroIMP entries are missing: " + ", ".join(missing))
    if not any(name.endswith(".rgg") for name in names):
        raise SystemExit("Archive contains no RGG source")
    if not any(name.endswith(".java") for name in names):
        raise SystemExit("Archive contains no Java source")

    for info in infos:
        name = info.filename
        normalized = posixpath.normpath(name)
        parts = pathlib.PurePosixPath(name).parts
        if (
            name.startswith("/")
            or "\\" in name
            or normalized != name
            or ".." in parts
            or name.startswith("Scripts/")
        ):
            raise SystemExit("Unsafe or incorrectly rooted archive entry: " + name)
        if name.endswith("/") or info.is_dir():
            raise SystemExit("Unexpected directory entry in normalized archive: " + name)
        if name == "Scripts.gsz" or name.endswith("/Scripts.gsz") or name.endswith(".gsz"):
            raise SystemExit("Archive contains a nested .gsz file: " + name)
        if info.date_time != expected_timestamp:
            raise SystemExit("Non-normalized timestamp for archive entry: " + name)
        if info.compress_type != zipfile.ZIP_STORED:
            raise SystemExit("Archive entry is not stored deterministically: " + name)
        if info.extra or info.comment:
            raise SystemExit("Archive entry contains unexpected ZIP metadata: " + name)
PY

if ! cmp -s "${EXPECTED_MANIFEST}" "${ARCHIVE_MANIFEST}"; then
  echo "Expected/source manifest versus archive manifest:" >&2
  diff -u "${EXPECTED_MANIFEST}" "${ARCHIVE_MANIFEST}" >&2 || true
  fail "Archive manifest does not exactly match Scripts/"
fi

mkdir -p "${EXTRACT_DIR}"
unzip -qq "${ARCHIVE_PATH}" -d "${EXTRACT_DIR}" \
  || fail "Archive extraction failed: ${ARCHIVE_PATH}"

(
  cd "${EXTRACT_DIR}"
  find . -type f -printf '%P\n' | LC_ALL=C sort
) > "${TEMP_DIR}/extracted.txt"
cmp -s "${EXPECTED_MANIFEST}" "${TEMP_DIR}/extracted.txt" \
  || fail "Extracted file manifest differs from the intended source manifest"

while IFS= read -r ENTRY; do
  cmp -- "${EXPECTED_DIR}/${ENTRY}" "${EXTRACT_DIR}/${ENTRY}" >/dev/null \
    || fail "Extracted content differs from canonical package source: ${ENTRY}"
done < "${EXPECTED_MANIFEST}"

echo "Scripts.gsz structural validation passed:"
echo "  archive: ${ARCHIVE_PATH}"
echo "  entries: $(wc -l < "${EXPECTED_MANIFEST}")"
echo "  layout : project files at archive root (no Scripts/ prefix)"
echo "  source : manifest and contents match the canonical package source"
echo "  project: ${METADATA_SOURCE}"
