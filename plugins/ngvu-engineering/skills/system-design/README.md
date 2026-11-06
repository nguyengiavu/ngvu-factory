# system-design

Design a NEW system or large feature at scale using the Big-Tech method. See `SKILL.md` for the pipeline.

## Produces
A `system-design/` folder of 11 reports (00–10): requirements → capacity estimation → API/data model →
high-level design → scaling → storage/consistency → async → reliability/bottlenecks → security/
multi-tenancy → tradeoffs/evaluation → assembled design doc/RFC.

## The promise
Every choice comes with **options → pros/cons → tradeoff axis → a scored decision matrix → a cited
source** (`reference/building-blocks.md`: DDIA, the relevant papers, official docs). Capacity numbers
show their working. Right-sizing is enforced — it names what would be over-engineering.

## Relationship to other skills
- Run **before** `technical-architecture` (which turns this blueprint into a concrete build plan).
- Hand the data tier to `dba-engineering`. Use `api-design` for a full contract, `adr` to record a
  decision, `tech-evaluation` for a specific tech pick.
- To evaluate something that already exists, use `system-analysis` / `bigtech-benchmark` instead.

## Output convention
`output/<project>/system-design/`.
