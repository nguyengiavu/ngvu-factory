# bigtech-benchmark

Benchmark a system against how hyperscalers (Google, YouTube, Netflix, Amazon/AWS,
Stripe) build and operate, then prescribe a **scored, evidence-backed, prioritized
upgrade plan**. See `SKILL.md` for the full pipeline.

## What it produces
A `bigtech-benchmark/` folder of 12 reports (00–11): a scope/target-setting baseline, eight pillar
benchmarks, a standardized 0–5 maturity scorecard, a waved upgrade roadmap, and an executive verdict.

## The three questions it answers for every weakness
1. **What** is the gap (current state, `file:line` evidence)?
2. **Why** does it matter — what do top systems do instead (named practice + real source) and what does
   inaction cost?
3. **How much / how urgently** — a standardized maturity score and a place on the roadmap.

## Key design choices
- **Two-sided evidence**: current state in *this* code (`file:line`) + target practice with a real source
  from `reference/bigtech-patterns.md` (cite it; do not invent sources).
- **Standardized scoring**: 0–5 capability maturity per pillar, reported as Current / Target / Gap.
- **Right-sizing, not cargo-culting**: recommend the level the system's real scale and criticality
  warrant; over-engineering is itself a finding (`10-upgrade-roadmap.md` has a "Do NOT do this" section).

## Best paired with
Run **after `system-analysis`** — it reads those reports as the current-state
baseline instead of re-deriving them. Can also run standalone with a light repo scan.

## Output location convention
`output/example/<service>/bigtech-benchmark/` (next to that service's `system-analysis/`).
