# FruitCropXL project knowledge

This directory provides compact, source-linked knowledge for developers,
reviewers, retrieval tools, and Codex.

## Ownership model

There are three deliberately different artifacts:

- `00_...` through `10_...` are focused, maintained notes. Update the relevant
  note when current code, configuration, runtime, or validation behavior
  changes.
- `.agents/skills/fruitcropxl/references/recent-stable-lessons.md` is the
  maintained home for non-obvious implementation and compatibility lessons.
  It is not a second project overview.
- `generated_knowledge_bundle.md` is the only broad-context derived copy. It
  combines the focused notes and curated agent lessons for systems that work
  better with one document. Never edit it directly.

The former four `20_combined_...` through `23_combined_...` documents were
removed because they manually repeated the focused notes and could drift.

## Update and check

After changing a focused note or the curated FruitCropXL lessons, run:

```bash
bash bash_scripts/update_project_knowledge.sh
```

The updater validates every manifest entry and declared source pattern,
refreshes content fingerprints, and rebuilds the shared bundle. To verify that
the generated files are current without changing them, run:

```bash
bash bash_scripts/update_project_knowledge.sh --check
```

`knowledge_manifest.json` is the machine-readable routing index. Its
`source_snapshot_sha256` covers the focused notes, their declared source files,
the FruitCropXL skill, and the curated lessons. A passing check therefore means
the generated bundle matches those inputs; it does not claim that every
scientific statement has been revalidated.

## Use guidance

- Use the focused files for precise topic retrieval and maintenance.
- Use `knowledge_manifest.json` for structured routing, tags, source anchors,
  and freshness checks.
- Use `generated_knowledge_bundle.md` only when a single larger upload or
  broad-context document is preferable.
- For implementation decisions, return to current `Scripts/`, scenario, test,
  and maintained documentation evidence rather than treating a summary as
  authoritative source code.
