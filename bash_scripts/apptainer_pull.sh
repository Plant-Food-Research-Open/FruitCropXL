#!/usr/bin/env bash
set -euo pipefail

# Normal development intentionally retains the mutable ``latest`` default.
# Release builds must opt in to --release and supply an immutable OCI digest.
GITHUB_APPTAINER_REPO="${GITHUB_APPTAINER_REPO:-oras://ghcr.io/junqi108/groimp}"
GITHUB_APPTAINER_TAG="${GITHUB_APPTAINER_TAG:-latest}"
GROIMP_APPTAINER_IMAGE="${GROIMP_APPTAINER_IMAGE:-groimp}"
GROIMP_APPTAINER_IMAGE_PATH="${GROIMP_APPTAINER_IMAGE_PATH:-images/groimp.sif}"
GROIMP_OCI_DIGEST="${GROIMP_OCI_DIGEST:-}"
RELEASE_MODE=0

usage() {
  cat <<'EOF'
Usage: bash bash_scripts/apptainer_pull.sh [--release]

Pull the GroIMP Apptainer image to images/groimp.sif by default.

Normal mode preserves the historic mutable tag default (latest). Set
GITHUB_APPTAINER_REPO and GITHUB_APPTAINER_TAG to override it.

Release mode requires GROIMP_OCI_DIGEST=sha256:<64-hex-digits> and pulls the
immutable oras reference <repository>@<digest>. It does not silently pin
normal development pulls.
EOF
}

for ARG in "$@"; do
  case "${ARG}" in
    --release) RELEASE_MODE=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "ERROR: Unsupported argument: ${ARG}" >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v apptainer >/dev/null 2>&1 || {
  echo "ERROR: apptainer is required" >&2
  exit 1
}

if [[ "${RELEASE_MODE}" == "1" ]]; then
  [[ "${GROIMP_OCI_DIGEST}" =~ ^sha256:[0-9a-fA-F]{64}$ ]] || {
    echo "ERROR: --release requires GROIMP_OCI_DIGEST=sha256:<64 hexadecimal digits>" >&2
    exit 1
  }
  IMAGE_REFERENCE="${GITHUB_APPTAINER_REPO}@${GROIMP_OCI_DIGEST}"
  TEMP_IMAGE_NAME="${GROIMP_APPTAINER_IMAGE}_release.sif"
else
  IMAGE_REFERENCE="${GITHUB_APPTAINER_REPO}:${GITHUB_APPTAINER_TAG}"
  TEMP_IMAGE_NAME="${GROIMP_APPTAINER_IMAGE}_${GITHUB_APPTAINER_TAG}.sif"
fi

mkdir -p "$(dirname "${GROIMP_APPTAINER_IMAGE_PATH}")"
[[ ! -e "${TEMP_IMAGE_NAME}" ]] || {
  echo "ERROR: Refusing to overwrite existing temporary pull output: ${TEMP_IMAGE_NAME}" >&2
  exit 1
}
apptainer pull --name "${TEMP_IMAGE_NAME}" "${IMAGE_REFERENCE}"
mv -- "${TEMP_IMAGE_NAME}" "${GROIMP_APPTAINER_IMAGE_PATH}"

echo "Pulled container source: ${GITHUB_APPTAINER_REPO}"
echo "Container tag: ${GITHUB_APPTAINER_TAG}"
echo "Container OCI digest: ${GROIMP_OCI_DIGEST:-unresolved}"
echo "Container SIF: ${GROIMP_APPTAINER_IMAGE_PATH}"
echo "Container SIF SHA-256: $(sha256sum "${GROIMP_APPTAINER_IMAGE_PATH}" | awk '{print $1}')"
