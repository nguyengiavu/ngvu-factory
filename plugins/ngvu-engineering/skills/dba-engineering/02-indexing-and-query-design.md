Act as a performance DBA designing indexes and queries.

Generate file: 02-indexing-and-query-design.md

For each access pattern from step 01, design the index that serves it and the query that uses it. NAME
the index type (cite engine-comparison.md §Indexing):
- **PostgreSQL**: B-tree, GIN (JSONB/array/FTS), GiST/SP-GiST (geo/range), BRIN (huge append-only),
  partial (`WHERE`), covering (`INCLUDE`), expression. Show `EXPLAIN (ANALYZE, BUFFERS)` for a key query.
- **MongoDB**: single/compound (apply the **ESR rule** — Equality, Sort, Range — for column order),
  multikey, partial, TTL, text, wildcard. Show `explain("executionStats")` for a key query.
- **MS SQL Server**: clustered vs nonclustered, filtered, covering (`INCLUDE`), columnstore (analytics).
  Show the execution-plan expectation; mention missing-index DMVs and statistics.

For each: the query, the index that makes it fast, the expected plan (index seek/scan, no full scan), and
**the cost of the index** (write amplification, storage) — the tradeoff. Flag any query that can't be
indexed well and why. Add pagination by default; eliminate N+1.

Output: Metadata header; access-pattern → index → query → expected-plan table; example DDL for each index;
the write-cost note per index. Right-size: don't over-index; each index has a write cost.
