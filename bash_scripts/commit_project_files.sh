#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

FILES=(
  "Scripts/project.gs"
  "Scripts/graph.xml"
  "Scripts/META-INF/MANIFEST.MF"
  "Scripts/workbench.options"
  "Scripts/Scripts.gsz"
)

while IFS= read -r GRAPH_FILE; do
  [[ -n "${GRAPH_FILE}" ]] && FILES+=("${GRAPH_FILE}")
done < <(git ls-files -- 'Scripts/graph.*.xml')

echo "Preparing tracked GroIMP project files for one intentional commit."
echo "This helper clears clone-local hide flags and stages files; it never commits."

for FILE in "${FILES[@]}"; do
  if [[ ! -f "${FILE}" ]]; then
    echo "ERROR: Required tracked project file is missing: ${FILE}" >&2
    exit 1
  fi
  # update-index treats these as separate per-path actions; combining them can
  # leave the skip-worktree bit set with some Git versions.
  git update-index --no-skip-worktree -- "${FILE}"
  git update-index --no-assume-unchanged -- "${FILE}"
done

git add -- "${FILES[@]}"

echo
echo "Staged GroIMP project files:"
git status --short -- "${FILES[@]}"
echo
echo "Review the staged content and create the final commit intentionally."
