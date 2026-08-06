# GroIMP / XL syntax notes for this repo

## Module and class style in this codebase
- RGG files mix Java-like declarations, globals, and XL graph queries.
- `import static <module>.*;` is heavily used for cross-module access.
- Keep compatibility-oriented Groovy/Java syntax (legacy GroIMP runtime).

## Rule forms used in GroIMP/XL context
- `==>`: standard rewrite/derivation rule.
- `==>>`: extended/sequenced rewrite behavior in XL derivation contexts.
- `::>`: guarded/context-sensitive production style (used in grammar-heavy modules).

Use the same form already present in the edited file; do not normalize syntax styles across modules.

## Query and graph traversal concepts
Common directional and repetition operators in project notes:
- `-->` any edge, `>` successor, `+>` branch.
- `()+`, `()*`, `()?` for repetition/optional patterns.
- Typical selection helpers: `first(...)`, `sum(...)`, `selectWhere(...)`.

## Branching and turtle context
- `[ ... ]` creates branch context and returns to branch origin after execution.
- Turtle loops use `for (1 : n) (...)` style; Java loops use `{ ... }` style.

## Parameter passing and updates
- Scenario/options propagate through global variables loaded from `model.options.*.json` categories.
- Organ and process updates rely on stepwise global states (`day`, `step`, thermal units).

## Practical pitfalls specific to this repo
- Avoid semantic alias conflicts in XL queries (do not reuse local var and XL alias names).
- Keep interface methods `public` where interface contracts require it.
- Do not add `derive()` during axiom initiation paths (project note: may empty graph/rule flow).
