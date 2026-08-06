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
METADATA_SOURCE="${GSZ_METADATA_SOURCE:-head}"
DEST_DIR=""
MANIFEST_PATH=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

usage() {
  cat >&2 <<'EOF'
Usage:
  bash bash_scripts/stage_gsz_sources.sh [--metadata-source=head|worktree] DEST_DIR MANIFEST_PATH

Materialize the canonical Scripts.gsz input tree. Normal project sources come
from the working tree. By default, GroIMP-managed project metadata comes from
HEAD so neither unstaged nor staged local GroIMP saves can change the archive.
Use --metadata-source=worktree only for an intentional project-metadata update
that will be committed together with Scripts.gsz.
EOF
}

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
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("${ARG}")
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

if ((${#POSITIONAL[@]} == 2)); then
  DEST_DIR="${POSITIONAL[0]}"
  MANIFEST_PATH="${POSITIONAL[1]}"
fi

[[ -n "${DEST_DIR}" && -n "${MANIFEST_PATH}" ]] || {
  usage
  exit 2
}
[[ -d "${SCRIPTS_DIR}" ]] || fail "Scripts source directory not found: ${SCRIPTS_DIR}"
[[ -s "${MANIFEST_PATH}" ]] || fail "Source manifest is missing or empty: ${MANIFEST_PATH}"

mkdir -p "${DEST_DIR}"
if find "${DEST_DIR}" -mindepth 1 -print -quit | grep -q .; then
  fail "Canonical source staging directory must be empty: ${DEST_DIR}"
fi

while IFS= read -r ENTRY; do
  [[ -n "${ENTRY}" ]] || fail "The source manifest contains an empty entry"
  DEST_PATH="${DEST_DIR}/${ENTRY}"
  install -D -m 0644 /dev/null "${DEST_PATH}"

  case "${ENTRY}" in
    project.gs|graph.xml|graph.*.xml|META-INF/MANIFEST.MF|workbench.options)
      if [[ "${METADATA_SOURCE}" == "head" ]]; then
        HEAD_PATH="Scripts/${ENTRY}"
        HEAD_BLOB="$(git -C "${REPO_ROOT}" rev-parse "HEAD:${HEAD_PATH}" 2>/dev/null || true)"
        [[ -n "${HEAD_BLOB}" ]] \
          || fail "GroIMP-managed project file must be tracked in HEAD: ${HEAD_PATH}"
        git -C "${REPO_ROOT}" cat-file blob "${HEAD_BLOB}" > "${DEST_PATH}"

        SOURCE_PATH="${SCRIPTS_DIR}/${ENTRY}"
        if [[ -f "${SOURCE_PATH}" ]]; then
          WORKTREE_BLOB="$(git hash-object --no-filters -- "${SOURCE_PATH}")"
          if [[ "${WORKTREE_BLOB}" != "${HEAD_BLOB}" ]]; then
            echo "NOTICE: ignoring local GroIMP project-file change: ${HEAD_PATH}" >&2
          fi
        else
          echo "NOTICE: using HEAD copy for locally missing GroIMP project file: ${HEAD_PATH}" >&2
        fi
      else
        SOURCE_PATH="${SCRIPTS_DIR}/${ENTRY}"
        [[ -f "${SOURCE_PATH}" ]] \
          || fail "Manifest project-file entry is missing from the working tree: ${ENTRY}"
        install -m 0644 -- "${SOURCE_PATH}" "${DEST_PATH}"
      fi
      ;;
    *)
      SOURCE_PATH="${SCRIPTS_DIR}/${ENTRY}"
      [[ -f "${SOURCE_PATH}" ]] || fail "Manifest entry is missing from Scripts/: ${ENTRY}"
      install -m 0644 -- "${SOURCE_PATH}" "${DEST_PATH}"
      ;;
  esac
done < "${MANIFEST_PATH}"
