#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DOC_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_SCRIPTS_DIR="${MODEL_DOC_DIR}/../Scripts"
STAGING_SCRIPTS_DIR="${SCRIPT_DIR}/Scripts"
HTML_DIR="${SCRIPT_DIR}/html"
TARGET_DOC_DIR="${MODEL_DOC_DIR}/FruitCropXL_doc"
DOXYFILE_PATH="${SCRIPT_DIR}/Doxyfile"

if [[ ! -d "${SOURCE_SCRIPTS_DIR}" ]]; then
  echo "ERROR: Source Scripts directory not found: ${SOURCE_SCRIPTS_DIR}" >&2
  exit 1
fi

if [[ ! -f "${DOXYFILE_PATH}" ]]; then
  echo "ERROR: Doxyfile not found: ${DOXYFILE_PATH}" >&2
  exit 1
fi

rm -rf "${STAGING_SCRIPTS_DIR}" "${HTML_DIR}"

cp -r "${SOURCE_SCRIPTS_DIR}" "${STAGING_SCRIPTS_DIR}"

# Doxygen parses Java-like syntax more reliably when XL/RGG 'module' declarations
# are converted to 'class' in the staging copy only.
find "${STAGING_SCRIPTS_DIR}" -type f \( -name "*.rgg" -o -name "*.xl" \) -print0 \
  | xargs -0 sed -i 's/\<module\>/class/g'

(
  cd "${SCRIPT_DIR}"
  doxygen "${DOXYFILE_PATH}"
)

if [[ ! -d "${HTML_DIR}" ]]; then
  echo "ERROR: Doxygen did not generate html output at ${HTML_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DOC_DIR}"
find "${TARGET_DOC_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "${HTML_DIR}/." "${TARGET_DOC_DIR}/"

rm -rf "${STAGING_SCRIPTS_DIR}" "${HTML_DIR}"

echo
echo "Model documentation generated and copied to: ${TARGET_DOC_DIR}"
echo "Open ${TARGET_DOC_DIR}/index.html"
