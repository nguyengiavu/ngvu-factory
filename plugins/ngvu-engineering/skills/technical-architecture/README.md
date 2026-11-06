# technical-architecture

Turn a chosen design into a concrete, buildable technical architecture AND the ordered setup sequence for
a new system/service/module. See `SKILL.md` for the pipeline.

## Produces
A `technical-architecture/` folder of 12 reports (00–11): intake/NFRs → context & boundaries → stack
selection → architecture style → integration & contracts → data architecture → security architecture →
reliability/resilience → observability-from-day-one → deployment & cloud → **the ordered setup-sequence
& scaffold checklist** → decision log (ADRs) & roadmap.

## The promise
Every decision: **options → pros/cons → tradeoff axis → scored matrix → cited source**
(`reference/architecture-patterns.md`). Security, observability, CI, and contracts are designed in from
step one (step 10 is a real ordered checklist with "why this is at this position"). Decisions are
recorded as ADRs. Right-sizing and platform-inheritance are enforced.

## Relationship to other skills
- Run **after** `system-design` (the abstract blueprint) — this makes it concretely buildable.
- Hand the data tier to `dba-engineering`; full API contracts to `api-design`; decision records to `adr`;
  tech picks to `tech-evaluation`.
- To review something that already exists, use `system-analysis` / `bigtech-benchmark`.

## Output convention
`output/<project>/technical-architecture/` (and an `adr/` folder for decision records).
