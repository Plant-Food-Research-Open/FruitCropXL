#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
PACKAGER="${REPO_ROOT}/bash_scripts/zip_groimp.sh"
VALIDATOR="${REPO_ROOT}/tests/gsz_test/validate_gsz_structure.sh"
METADATA_GENERATOR="${REPO_ROOT}/bash_scripts/create_release_metadata.sh"

VERSION=""
OUTPUT_ROOT="${REPO_ROOT}/build/release"
SIF_PATH="${REPO_ROOT}/images/groimp.sif"
CONTAINER_SOURCE="${CONTAINER_SOURCE:-oras://ghcr.io/junqi108/groimp}"
CONTAINER_TAG="${CONTAINER_TAG:-latest}"
CONTAINER_OCI_DIGEST="${CONTAINER_OCI_DIGEST:-}"
INCLUDE_SIF=0
ALLOW_DIRTY=0

usage() {
  cat <<'EOF'
Usage: bash bash_scripts/build_release_package.sh --version VERSION [options]

Build a non-published FruitCropXL release candidate. VERSION is required; the
script never creates a Git tag or GitHub Release.

Options:
  --version VERSION              Release version (required; no path separators)
  --output-dir PATH              Parent directory for FruitCropXL-VERSION
  --container PATH               Exact GroIMP .sif to identify
  --container-source VALUE       OCI/ORAS source
  --container-tag VALUE          Descriptive source tag
  --container-oci-digest VALUE   Immutable OCI digest, if resolved
  --include-sif                  Copy the SIF into the package (off by default)
  --allow-dirty                  Build a marked non-release candidate from a dirty checkout

A clean checkout is required by default. --allow-dirty records git_dirty=true
in metadata and is intended only for local machinery tests, not publication.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --version|--output-dir|--container|--container-source|--container-tag|--container-oci-digest)
      (($# >= 2)) || fail "Missing value for $1"
      case "$1" in
        --version) VERSION="$2" ;;
        --output-dir) OUTPUT_ROOT="$2" ;;
        --container) SIF_PATH="$2" ;;
        --container-source) CONTAINER_SOURCE="$2" ;;
        --container-tag) CONTAINER_TAG="$2" ;;
        --container-oci-digest) CONTAINER_OCI_DIGEST="$2" ;;
      esac
      shift 2
      ;;
    --include-sif) INCLUDE_SIF=1; shift ;;
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unsupported argument: $1" ;;
  esac
done

[[ -n "${VERSION}" ]] || fail "--version is required; no version or tag is invented"
[[ "${VERSION}" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$ ]] || fail "Version contains unsupported characters: ${VERSION}"
[[ -x "${PACKAGER}" ]] || fail "Packager is not executable: ${PACKAGER}"
[[ -x "${VALIDATOR}" ]] || fail "Validator is not executable: ${VALIDATOR}"
[[ -x "${METADATA_GENERATOR}" ]] || fail "Metadata generator is not executable: ${METADATA_GENERATOR}"
[[ -s "${SIF_PATH}" ]] || fail "Container SIF is missing or empty: ${SIF_PATH}"
command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is required"

GIT_STATUS="$(git -C "${REPO_ROOT}" status --porcelain --untracked-files=all)"
if [[ -n "${GIT_STATUS}" && "${ALLOW_DIRTY}" != "1" ]]; then
  echo "Checkout has uncommitted or untracked files:" >&2
  printf '%s\n' "${GIT_STATUS}" >&2
  fail "Refusing a dirty release candidate; use --allow-dirty only for a marked local test"
fi

PACKAGE_DIR="${OUTPUT_ROOT}/FruitCropXL-${VERSION}"
[[ ! -e "${PACKAGE_DIR}" ]] || fail "Release package destination already exists: ${PACKAGE_DIR}"
mkdir -p "${PACKAGE_DIR}"

GSZ_OUTPUT="${PACKAGE_DIR}/Scripts.gsz"
echo "Building authoritative Scripts.gsz release artifact..."
GSZ_ARCHIVE_PATH="${GSZ_OUTPUT}" "${PACKAGER}"
"${VALIDATOR}" "${GSZ_OUTPUT}"

GIT_DIRTY=false
[[ -n "${GIT_STATUS}" ]] && GIT_DIRTY=true
"${METADATA_GENERATOR}" \
  --output "${PACKAGE_DIR}/release-metadata.json" \
  --scripts-gsz "${GSZ_OUTPUT}" \
  --container "${SIF_PATH}" \
  --container-source "${CONTAINER_SOURCE}" \
  --container-tag "${CONTAINER_TAG}" \
  --container-oci-digest "${CONTAINER_OCI_DIGEST}" \
  --git-dirty "${GIT_DIRTY}"

if [[ "${INCLUDE_SIF}" == "1" ]]; then
  cp -- "${SIF_PATH}" "${PACKAGE_DIR}/$(basename "${SIF_PATH}")"
fi

(
  cd "${PACKAGE_DIR}"
  if [[ "${INCLUDE_SIF}" == "1" ]]; then
    sha256sum Scripts.gsz release-metadata.json "$(basename "${SIF_PATH}")" > SHA256SUMS
  else
    sha256sum Scripts.gsz release-metadata.json > SHA256SUMS
  fi
  sha256sum -c SHA256SUMS
)

echo "Release candidate assembled: ${PACKAGE_DIR}"
echo "No Git tag or GitHub Release was created."
