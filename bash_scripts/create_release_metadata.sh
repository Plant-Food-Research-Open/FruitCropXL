#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"

OUTPUT="release-metadata.json"
GSZ_PATH="${REPO_ROOT}/Scripts/Scripts.gsz"
SIF_PATH="${REPO_ROOT}/images/groimp.sif"
CONTAINER_SOURCE="${CONTAINER_SOURCE:-oras://ghcr.io/junqi108/groimp}"
CONTAINER_TAG="${CONTAINER_TAG:-latest}"
CONTAINER_OCI_DIGEST="${CONTAINER_OCI_DIGEST:-}"
REPOSITORY="${FRUITCROPXL_REPOSITORY:-Plant-Food-Research-Open/FruitCropXL}"
GIT_DIRTY="${GIT_DIRTY:-}"

usage() {
  cat <<'EOF'
Usage: bash bash_scripts/create_release_metadata.sh [options]

Create machine-readable provenance for a built FruitCropXL release candidate.

Options:
  --output PATH                 Metadata destination (default: release-metadata.json)
  --scripts-gsz PATH            Built Scripts.gsz to record
  --container PATH              Exact GroIMP .sif used for the build
  --container-source VALUE      OCI/ORAS source (default: oras://ghcr.io/junqi108/groimp)
  --container-tag VALUE         Descriptive source tag (default: latest)
  --container-oci-digest VALUE  Immutable sha256 OCI digest, if resolved
  --repository OWNER/REPO       Canonical source repository
  --git-dirty true|false        Explicit checkout-state marker
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --output|--scripts-gsz|--container|--container-source|--container-tag|--container-oci-digest|--repository|--git-dirty)
      (($# >= 2)) || fail "Missing value for $1"
      case "$1" in
        --output) OUTPUT="$2" ;;
        --scripts-gsz) GSZ_PATH="$2" ;;
        --container) SIF_PATH="$2" ;;
        --container-source) CONTAINER_SOURCE="$2" ;;
        --container-tag) CONTAINER_TAG="$2" ;;
        --container-oci-digest) CONTAINER_OCI_DIGEST="$2" ;;
        --repository) REPOSITORY="$2" ;;
        --git-dirty) GIT_DIRTY="$2" ;;
      esac
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unsupported argument: $1" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || fail "python3 is required"
command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is required"
[[ -s "${GSZ_PATH}" ]] || fail "Scripts.gsz is missing or empty: ${GSZ_PATH}"
[[ -s "${SIF_PATH}" ]] || fail "Container SIF is missing or empty: ${SIF_PATH}"

if [[ -z "${GIT_DIRTY}" ]]; then
  if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain --untracked-files=all)" ]]; then
    GIT_DIRTY=true
  else
    GIT_DIRTY=false
  fi
fi
[[ "${GIT_DIRTY}" == "true" || "${GIT_DIRTY}" == "false" ]] || fail "--git-dirty must be true or false"
if [[ -n "${CONTAINER_OCI_DIGEST}" && ! "${CONTAINER_OCI_DIGEST}" =~ ^sha256:[0-9a-fA-F]{64}$ ]]; then
  fail "Container OCI digest must be sha256:<64 hexadecimal digits>"
fi

GIT_COMMIT="$(git -C "${REPO_ROOT}" rev-parse HEAD)"
GIT_TAG="$(git -C "${REPO_ROOT}" describe --exact-match --tags HEAD 2>/dev/null || true)"
GSZ_SHA256="$(sha256sum "${GSZ_PATH}" | awk '{print $1}')"
SIF_SHA256="$(sha256sum "${SIF_PATH}" | awk '{print $1}')"
BUILD_TIMESTAMP_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
APPTAINER_VERSION=""
JAVA_VERSION=""
GROIMP_VERSION=""

if command -v apptainer >/dev/null 2>&1; then
  APPTAINER_VERSION="$(apptainer --version 2>/dev/null || true)"
  if JAVA_OUTPUT="$(apptainer exec "${SIF_PATH}" java -version 2>&1)"; then
    JAVA_VERSION="$(printf '%s\n' "${JAVA_OUTPUT}" | sed -n '1p')"
  else
    echo "WARNING: Could not determine Java version from container; recording null." >&2
  fi
  GROIMP_VERSION="$(apptainer inspect --labels "${SIF_PATH}" 2>/dev/null | sed -n 's/^Version: *//p' | sed -n '1p' || true)"
fi

export RELEASE_METADATA_OUTPUT="${OUTPUT}"
export RELEASE_METADATA_GIT_COMMIT="${GIT_COMMIT}"
export RELEASE_METADATA_GIT_TAG="${GIT_TAG}"
export RELEASE_METADATA_REPOSITORY="${REPOSITORY}"
export RELEASE_METADATA_GIT_DIRTY="${GIT_DIRTY}"
export RELEASE_METADATA_GSZ_FILE="$(basename "${GSZ_PATH}")"
export RELEASE_METADATA_GSZ_SHA256="${GSZ_SHA256}"
export RELEASE_METADATA_CONTAINER_SOURCE="${CONTAINER_SOURCE}"
export RELEASE_METADATA_CONTAINER_TAG="${CONTAINER_TAG}"
export RELEASE_METADATA_CONTAINER_OCI_DIGEST="${CONTAINER_OCI_DIGEST}"
export RELEASE_METADATA_CONTAINER_SIF_SHA256="${SIF_SHA256}"
export RELEASE_METADATA_APPTAINER_VERSION="${APPTAINER_VERSION}"
export RELEASE_METADATA_JAVA_VERSION="${JAVA_VERSION}"
export RELEASE_METADATA_GROIMP_VERSION="${GROIMP_VERSION}"
export RELEASE_METADATA_BUILD_TIMESTAMP_UTC="${BUILD_TIMESTAMP_UTC}"

python3 - <<'PY'
import json
import os
from pathlib import Path

def nullable(value):
    return value or None

metadata = {
    "fruitcropxl": {
        "git_commit": os.environ["RELEASE_METADATA_GIT_COMMIT"],
        "git_tag": nullable(os.environ["RELEASE_METADATA_GIT_TAG"]),
        "repository": os.environ["RELEASE_METADATA_REPOSITORY"],
        "git_dirty": os.environ["RELEASE_METADATA_GIT_DIRTY"] == "true",
    },
    "groimp_project": {
        "file": os.environ["RELEASE_METADATA_GSZ_FILE"],
        "sha256": os.environ["RELEASE_METADATA_GSZ_SHA256"],
    },
    "container": {
        "source": nullable(os.environ["RELEASE_METADATA_CONTAINER_SOURCE"]),
        "tag": nullable(os.environ["RELEASE_METADATA_CONTAINER_TAG"]),
        "oci_digest": nullable(os.environ["RELEASE_METADATA_CONTAINER_OCI_DIGEST"]),
        "sif_sha256": os.environ["RELEASE_METADATA_CONTAINER_SIF_SHA256"],
    },
    "runtime": {
        "apptainer_version": nullable(os.environ["RELEASE_METADATA_APPTAINER_VERSION"]),
        "java_version": nullable(os.environ["RELEASE_METADATA_JAVA_VERSION"]),
        "groimp_version": nullable(os.environ["RELEASE_METADATA_GROIMP_VERSION"]),
    },
    "build": {"timestamp_utc": os.environ["RELEASE_METADATA_BUILD_TIMESTAMP_UTC"]},
}

output = Path(os.environ["RELEASE_METADATA_OUTPUT"])
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

echo "Created release metadata: ${OUTPUT}"
