#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILDER="${REPO_ROOT}/bash_scripts/build_release_package.sh"
VALIDATOR="${REPO_ROOT}/tests/gsz_test/validate_gsz_structure.sh"
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

[[ -x "${BUILDER}" ]] || fail "Release builder is not executable: ${BUILDER}"
[[ -x "${VALIDATOR}" ]] || fail "Archive validator is not executable: ${VALIDATOR}"
[[ -s "${REPO_ROOT}/images/groimp.sif" ]] || fail "Local container SIF is required for this test"

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/fruitcropxl-release-package.XXXXXX")"
VERSION="test-release-candidate"
"${BUILDER}" --version "${VERSION}" --output-dir "${TEMP_ROOT}" --allow-dirty

PACKAGE_DIR="${TEMP_ROOT}/FruitCropXL-${VERSION}"
[[ -f "${PACKAGE_DIR}/Scripts.gsz" ]] || fail "Package is missing Scripts.gsz"
[[ -f "${PACKAGE_DIR}/release-metadata.json" ]] || fail "Package is missing release metadata"
[[ -f "${PACKAGE_DIR}/SHA256SUMS" ]] || fail "Package is missing SHA256SUMS"

python3 - "${PACKAGE_DIR}/release-metadata.json" "${PACKAGE_DIR}/Scripts.gsz" "${REPO_ROOT}/images/groimp.sif" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

metadata_path, gsz_path, sif_path = map(pathlib.Path, sys.argv[1:])
metadata = json.loads(metadata_path.read_text(encoding="utf-8"))

def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

if metadata["fruitcropxl"]["git_commit"] != subprocess.check_output(
    ["git", "rev-parse", "HEAD"], text=True
).strip():
    raise SystemExit("Metadata git commit does not match checked-out commit")
if metadata["groimp_project"]["sha256"] != sha256(gsz_path):
    raise SystemExit("Metadata Scripts.gsz checksum does not match package file")
if metadata["container"]["sif_sha256"] != sha256(sif_path):
    raise SystemExit("Metadata SIF checksum does not match exact container")
if metadata["fruitcropxl"]["git_dirty"] is not True:
    raise SystemExit("--allow-dirty test must mark metadata as dirty")
PY

(cd "${PACKAGE_DIR}" && sha256sum -c SHA256SUMS)
"${VALIDATOR}" "${PACKAGE_DIR}/Scripts.gsz"

if "${BUILDER}" --output-dir "${TEMP_ROOT}" --allow-dirty >/dev/null 2>&1; then
  fail "Release builder accepted a missing required version"
fi
if "${BUILDER}" --version missing-container --output-dir "${TEMP_ROOT}" \
  --container "${TEMP_ROOT}/missing-groimp.sif" --allow-dirty >/dev/null 2>&1; then
  fail "Release builder accepted a missing required container artifact"
fi

echo "Release package provenance test passed: ${PACKAGE_DIR}"
