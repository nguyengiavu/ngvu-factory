# Engine comparison & mechanisms: PostgreSQL · MongoDB · MS SQL Server (cite from here)

Engine-specific mechanisms with sources. Cite when recommending. Mark others `[unverified]`. Sources:
official manuals (postgresql.org/docs, mongodb.com/docs, learn.microsoft.com/sql), **DDIA** (Kleppmann),
**Use The Index, Luke!** (Winand) for indexing.

## When to pick which (tradeoff summary)
| Need | PostgreSQL | MongoDB | MS SQL Server |
|---|---|---|---|
| Rich relational queries, joins, strong ACID | ★ best (OSS) | weak (joins via `$lookup`) | ★ best (enterprise) |
| Flexible / hierarchical / evolving schema | JSONB (good) | ★ native document | JSON column (ok) |
| Horizontal write scale / sharding | manual (Citus) | ★ native sharding | limited |
| Analytics / OLAP on same engine | ok (+ extensions) | aggregation pipeline | ★ columnstore |
| Microsoft / .NET ecosystem | neutral | neutral | ★ native | 
| Cost / licensing | ★ free OSS | free OSS / Atlas | $$ licensed (Express free, capped) |
| Geospatial / full-text / extensibility | ★ PostGIS, extensions | geo + text ok | ok |
Source: DDIA ch.2–3; each engine's manual; AWS purpose-built DBs.

## Data modeling
- **PostgreSQL**: normalized relational + selective denormalization; `JSONB` for flexible sub-structures
  (index with GIN); arrays, composite types, enums. Source: PG docs "Data Types", "JSON Types".
- **MongoDB**: embed for "contains"/read-together (1:few, bounded), reference for 1:many/many:many or
  unbounded growth; watch the 16 MB document cap; design around access patterns, not entities. Source:
  MongoDB "Data Modeling", "Building with Patterns".
- **MS SQL Server**: relational; `clustered index = physical order` (choose the clustering key
  deliberately); filegroups/partitions; `JSON`/`sql_variant` sparingly. Source: SQL Server "Clustered and
  Nonclustered Indexes Described".

## Indexing
- **PostgreSQL**: B-tree (default), **GIN** (JSONB/arrays/full-text), **GiST/SP-GiST** (geo/range),
  **BRIN** (huge append-only), **partial** (`WHERE`), **covering** (`INCLUDE`), expression indexes.
  Read plans with `EXPLAIN (ANALYZE, BUFFERS)`. Source: PG "Indexes"; Use The Index, Luke!.
- **MongoDB**: single-field, **compound** (order matters — ESR rule: Equality, Sort, Range), **multikey**
  (arrays), **text**, **wildcard**, **partial**, **TTL** (auto-expire). Read plans with `explain()`
  ("queryPlanner"/"executionStats"). Source: MongoDB "Indexes", "ESR Rule".
- **MS SQL Server**: clustered (1/table), nonclustered, **filtered**, **covering** (`INCLUDE`),
  **columnstore** (analytics, huge compression), indexed views. Read plans with actual/estimated
  execution plan; watch missing-index DMVs and stats. Source: SQL Server "Indexes", "Columnstore".

## Transactions & consistency
- **PostgreSQL**: MVCC; isolation Read Committed (default), Repeatable Read, Serializable (SSI —
  true serializable via predicate locks). Source: PG "Transaction Isolation".
- **MongoDB**: single-document writes atomic; multi-document ACID transactions since 4.0 (replica set) /
  4.2 (sharded) but with cost — prefer a model that keeps a transaction within one document.
  **Read/write concern** tune consistency/durability (`w:majority`, `readConcern:majority/linearizable`).
  Source: MongoDB "Transactions", "Read/Write Concern".
- **MS SQL Server**: locking + isolation levels incl. **RCSI/Snapshot** (row-versioning, avoids
  reader/writer blocking) — enabling RCSI is a common tuning win. Source: SQL Server "Transaction Locking
  and Row Versioning".
- **Distributed**: avoid 2PC where possible; prefer sagas / outbox / idempotency. Source: DDIA ch.7,9;
  microservices.io "Saga".

## Performance tuning
- **PostgreSQL**: `shared_buffers`, `work_mem`, `effective_cache_size`; **autovacuum** (bloat/wraparound
  — tune, don't disable); connection pooling via **PgBouncer** (PG connections are heavy); partitioning
  (declarative range/list/hash). Source: PG "Server Configuration", "Routine Vacuuming".
- **MongoDB**: keep the **working set in RAM** (WiredTiger cache); covered queries; avoid unbounded
  arrays; shard key choice is critical and hard to change. Source: MongoDB "Production Notes", "Sharding".
- **MS SQL Server**: size/tune **tempdb** (multiple files), keep **statistics** fresh, watch parameter
  sniffing, use Query Store; columnstore for analytics. Source: SQL Server "tempdb", "Query Store".

## HA / replication / scaling
- **PostgreSQL**: streaming replication (sync/async) + hot standbys; logical replication for
  selective/upgrade; auto-failover via **Patroni**/repmgr. Read replicas for read scale; Citus for shard.
  Source: PG "High Availability"; Patroni docs.
- **MongoDB**: **replica set** (auto-failover, 1 primary + secondaries; majority writes for durability);
  **sharding** for horizontal scale (mongos + config servers + shards). Source: MongoDB "Replication",
  "Sharding".
- **MS SQL Server**: **Always On Availability Groups** (sync/async replicas, readable secondaries),
  failover cluster instances, log shipping. Source: SQL Server "Always On Availability Groups".
- Always state **RPO** (data-loss window) and **RTO** (recovery time) of the chosen topology.

## Backup & DR
- **PostgreSQL**: `pg_basebackup` + WAL archiving → **PITR**; logical `pg_dump`. Source: PG "Backup".
- **MongoDB**: `mongodump`/`mongorestore`, filesystem/cloud snapshots, **oplog** for PITR (Atlas/Ops
  Manager continuous backup). Source: MongoDB "Back Up and Restore".
- **MS SQL Server**: full + differential + transaction-log backups → PITR; verify with restore drills.
  Source: SQL Server "Back Up and Restore". **Test restores regularly — an untested backup is a hope.**

## Security & access
- **PostgreSQL**: roles/`GRANT`, **Row-Level Security (RLS)** (great for multi-tenant), `pgcrypto`/TDE
  (cloud), SSL/`scram-sha-256`, `pgaudit`. Source: PG "Database Roles", "Row Security Policies".
- **MongoDB**: SCRAM/x.509 auth, RBAC, **encryption at rest** (WiredTiger / Enterprise), TLS, field-level
  encryption, auditing (Enterprise/Atlas). Source: MongoDB "Security".
- **MS SQL Server**: logins/users/roles, **TDE** (encryption at rest), Always Encrypted (column),
  **Row-Level Security**, Dynamic Data Masking, auditing. Source: SQL Server "Security Center".
- Common: least privilege, separate app vs admin accounts, encrypt in transit, audit sensitive access.

## Migrations & ops
- **Expand/contract** for zero-downtime schema change. Online DDL: PG (most `ALTER` are fast; index
  builds `CREATE INDEX CONCURRENTLY`; beware long locks); MongoDB schema is flexible but backfills need
  batching; MSSQL `ONLINE = ON` index ops (Enterprise). Source: db-migration skill; PG/Mongo/MSSQL docs;
  gh-ost lineage for the pattern.

## Right-sizing
- A single well-tuned node of any of these handles a lot. Reach for sharding (Mongo) / Citus (PG) /
  scale-out only with measured evidence; read replicas + caching + indexing usually come first.
- Don't pay SQL Server licensing or run AlwaysOn for a workload a single Postgres node serves; don't pick
  MongoDB for a richly-relational, join-heavy domain just for "flexible schema". Match engine to workload.
