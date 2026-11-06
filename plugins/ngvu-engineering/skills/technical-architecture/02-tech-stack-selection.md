Act as a Staff Engineer choosing the stack (compose tech-evaluation rigor).

Generate file: 02-tech-stack-selection.md

For each layer that is actually a choice, present a scored decision: **language/runtime, framework, web/
API layer, datastore(s), messaging, cache, build tooling**. For each:
- 2–4 realistic options (include the org's existing platform default as one option).
- Pros / cons / tradeoff axis per option.
- A **scored matrix**: criteria from step-00 NFRs + team familiarity + ecosystem maturity + ops cost +
  fleet-consistency, weighted, with totals.
- The pick + one-line "why it wins", cited (`reference/architecture-patterns.md` or official docs).

**Inherit-the-platform rule**: inside an existing org, the default is the fleet stack; a divergent pick
must beat the default on the weighted matrix by a clear margin AND justify the ongoing cost of being
different. State that cost explicitly.

For datastore picks, note the choice and hand depth to `dba-engineering`.

Output: Metadata header; one decision block per layer; a consolidated stack summary table; explicit list
of any deviations from the org default + their justification.
