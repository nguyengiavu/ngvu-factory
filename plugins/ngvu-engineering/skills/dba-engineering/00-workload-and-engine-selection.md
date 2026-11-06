Act as a Principal DBA characterizing the workload and choosing the engine.

Generate file: 00-workload-and-engine-selection.md

First, **profile the workload** (observed vs inferred): OLTP / OLAP / mixed; read:write ratio; query
shapes (point lookups, joins, range scans, aggregations, full-text, geo); data shape (relational,
hierarchical/document, KV); consistency need (strong vs eventual); scale (rows/docs, GB/TB, QPS, growth);
latency/availability targets; team familiarity; licensing/cost; managed-service options.

Then choose among **PostgreSQL / MongoDB / MS SQL Server** with a scored decision matrix:
- Criteria (weighted by the profile): query richness/joins, schema flexibility, write/scale-out, analytics,
  consistency/ACID, ecosystem fit, cost/licensing, ops & team skill, managed-service maturity.
- For each engine: pros / cons / where it shines / where it hurts for THIS workload.
- Weighted totals + the pick + "why it wins, why the others lost". Cite `reference/engine-comparison.md`
  (the when-to-pick-which table + sources).

**Right-size**: if the workload fits one well-tuned node, say so and do not pick for imaginary scale.
If the org/platform already imposes an engine (e.g. Mongo through a shared document service, or PostgreSQL direct), state
that and frame the analysis as "is the imposed engine appropriate, and how to use it well".

Output: Metadata header (project, file, engine(s), date, confidence); workload profile; engine decision
matrix; recommendation with rationale; Assumptions/Missing Information.
