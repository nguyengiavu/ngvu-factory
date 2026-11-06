# dba-engineering

Engineer the database tier across **PostgreSQL, MongoDB, and MS SQL Server** — workload-first, comparative,
engine-specific. See `SKILL.md` for the pipeline.

## Produces
A `dba-engineering/` folder of 10 reports (00–09): workload profile & engine selection → data modeling →
indexing & query design → transactions & consistency → performance tuning → HA/replication/scaling →
backup & DR → security & access → migrations & operations → final engine tradeoff scorecard.

## The promise
Every recommendation **names the engine-specific mechanism** (PG GIN/BRIN/partial; Mongo compound/ESR/TTL;
MSSQL clustered/filtered/columnstore), gives **options → pros/cons → tradeoff → scored matrix → cited
source** (`reference/engine-comparison.md`: official manuals + DDIA), and states **numeric RPO/RTO** for
any HA/DR choice. Right-sizing is enforced — it flags sharding/columnstore/AlwaysOn when a single tuned
node suffices.

## Relationship to other skills
- Goes deeper and multi-engine than `db-schema-design` (one schema), `db-migration` (one change) — compose those for narrow tasks.
- Receives the datastore choice from `system-design` / `technical-architecture`.
- For a single slow query / EXPLAIN, use `sql-optimization`.

## Output convention
`output/<project>/dba-engineering/`.
