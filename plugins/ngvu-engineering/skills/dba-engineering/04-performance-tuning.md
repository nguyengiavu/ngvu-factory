Act as a performance DBA tuning the engine.

Generate file: 04-performance-tuning.md

Engine-specific tuning (cite engine-comparison §Performance):
- **PostgreSQL**: `shared_buffers`, `work_mem`, `effective_cache_size`, `max_connections`; **autovacuum**
  tuning (bloat + transaction-ID wraparound — never disable); **PgBouncer** pooling (PG connections are
  heavy); declarative **partitioning** (range/list/hash) for large tables.
- **MongoDB**: keep the **working set in RAM** (WiredTiger cache sizing); covered queries; avoid unbounded
  arrays/large docs; shard-key choice (critical, hard to change); read preference for replicas.
- **MS SQL Server**: size & multi-file **tempdb**; keep **statistics** fresh; watch parameter sniffing;
  Query Store for regressions; columnstore for analytics; MAXDOP/cost-threshold.

Cross-engine: **connection pooling** (app-side sizing: replicas x pool ≤ server max), caching layer,
batching, avoiding N+1 (link step 02), and reconciling the **connection budget** against the server limit.

For each lever: what it does, the symptom it addresses, the value/approach, and the **tradeoff/risk** of
over-tuning (e.g. too-large `work_mem` x many connections → OOM). Show example config snippets.

Output: Metadata header; per-engine tuning table (parameter | purpose | suggested approach | risk);
connection-budget calc; partitioning/working-set plan. Right-size: measure before tuning; don't cargo-cult
config.
