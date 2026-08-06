# Coding conventions (repo-specific)

## Compatibility baseline
- Maintain legacy GroIMP/Groovy/Java compatibility patterns.
- Target Java 1.5-friendly style in shared/legacy-sensitive code paths.

## Explicit compatibility rules
- Prefer `Double.valueOf(value)` instead of `new Double(value)`.
- Avoid introducing modern generic syntax where compatibility is uncertain.
- Do not use diamond operator `<>` in compatibility-sensitive Java code.
- Use raw `Map`/legacy collection style where existing modules depend on it.

## GroIMP/XL style alignment
- Follow local RGG/XL style in edited module (imports, global declarations, query style).
- Do not wrap imports in try/catch.
- For newly introduced variables depending on optional legacy fields, add localized compatibility guards (`try/catch`) with explicit defaults.

## Model-safe change rules
- Keep diffs minimal and localized.
- Do not rename/remove core `.gs`, `.gsz`, `.rgg`, `.xl`, `graph.xml`, or image assets without explicit request.
- Preserve output units, column order, and schema stability.

## Scenario and naming conventions
- Keep existing scenario naming patterns (`model.options.*.json`, etc.).
- Keep configuration category/key usage synchronized with config guides and templates.
