#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
FRUIT_BASE="${REPO_ROOT}/Scripts/organs/absOrgans/fruitBase.rgg"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

rg -q 'public module SimpleFruit extends BerrySimple' "${FRUIT_BASE}" \
  || fail "SimpleFruit compatibility-preserving module is missing"
rg -q 'public module ComplexBerry extends BerryComplex' "${FRUIT_BASE}" \
  || fail "ComplexBerry compatibility-preserving module is missing"
rg -q 'public SimpleFruit[(]String fruitParams, int delta[)]' "${FRUIT_BASE}" \
  || fail "SimpleFruit string-parameter constructor is missing"
rg -q 'public SimpleFruit[(]ParametersFactory parametersFactory, int delta[)]' "${FRUIT_BASE}" \
  || fail "SimpleFruit ParametersFactory constructor is missing"
rg -q 'public ComplexBerry[(]String fruitParams, int delta[)]' "${FRUIT_BASE}" \
  || fail "ComplexBerry string-parameter constructor is missing"
rg -q 'public ComplexBerry[(]ParametersFactory parametersFactory, int delta[)]' "${FRUIT_BASE}" \
  || fail "ComplexBerry ParametersFactory constructor is missing"
rg -q 'return SimpleFruit[.]class;' "${FRUIT_BASE}" \
  || fail 'fruitModule="simpleFruit" does not select SimpleFruit'
rg -q 'return ComplexBerry[.]class;' "${FRUIT_BASE}" \
  || fail 'fruitModule="complexBerry" does not select ComplexBerry'
rg -q 'return VirtualFruit[.]class;' "${FRUIT_BASE}" \
  || fail 'fruitModule="virtualFruit" does not select VirtualFruit'

if rg -n 'return Berry(Simple|Complex)[.]class;' "${FRUIT_BASE}"; then
  fail "FruitCreator still actively selects a legacy fruit class"
fi

rg -q 'simpleFruit.*SimpleFruit.*complexBerry.*ComplexBerry.*virtualFruit.*VirtualFruit' \
  "${REPO_ROOT}/Model_documents/config-execution/model-options-guide.md" \
  || fail "model-options guide does not document selector-to-class mappings"

echo "Fruit module selector-to-class mapping check passed."
