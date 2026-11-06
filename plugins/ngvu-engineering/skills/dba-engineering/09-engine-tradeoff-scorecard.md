Act as a Principal DBA delivering the final verdict.

Generate file: 09-engine-tradeoff-scorecard.md

Consolidate steps 00–08 into the decision-ready scorecard the user can act on. Do NOT re-derive — summarize.

Produce:
- **Comparative scorecard** for THIS workload: rows = PostgreSQL / MongoDB / MS SQL Server; columns =
  the weighted criteria from step 00 (query richness, schema flexibility, write/scale-out, analytics,
  consistency/ACID, ecosystem fit, cost, ops/skill, managed maturity); cells = 0–5 with a one-line reason;
  weighted totals. State the weights explicitly.
- **Recommendation**: the chosen engine + a one-paragraph rationale tying the score to the workload, and
  a short "when this choice would change" (the trigger to revisit — e.g. write QPS 10x, analytics need).
- **Runner-up & when to prefer it** — be honest about the close calls.
- **Key design decisions carried** (model, top indexes, isolation, HA topology with RPO/RTO, backup,
  security highlights) — the one-page summary of the whole data-tier design.
- **Risks & mitigations**, and **what would be over-engineering** for this workload (e.g. sharding,
  columnstore, AlwaysOn) with why.

Cite engine-comparison.md throughout.

Output: Metadata header (engines compared, date); the scorecard; recommendation + revisit triggers;
runner-up; design summary; risks; over-engineering-avoided list. This is the page a lead approves.
