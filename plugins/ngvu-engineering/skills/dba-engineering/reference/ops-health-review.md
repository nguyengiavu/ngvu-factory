# Ops / health review (running database)

The day-2 branch of dba-engineering: review and harden a database that already runs. It adds the health
checklist, archival and capacity work below, then reuses steps 04–07 for tuning, HA, backup/DR and
security. Output: `ops-health-review.md` in the `dba-engineering/` folder, plus any of 04–07 that the
findings call for.

## Steps
1. **Find the store** for the service: `persistence.xml` / `pom.xml` (JPA + Postgres), a Mongo client, or
   a shared document service over REST (then the store belongs to that service).
2. **Health check**, reading workload state with `ngvu-pod-health`
   and logs time-bounded per [`cost-token-policy.md`](~/.claude/rules/cost-token-policy.md):
   - **PostgreSQL**: cache hit ratio; `pg_stat_statements` / slow-query log; index usage vs unused
     indexes; table/index bloat; autovacuum and stats freshness; lock waits and long-running transactions;
     connections vs `max_connections`; replication lag; disk headroom and growth; error log.
   - **MongoDB**: `COLLSCAN` vs index usage; profiler / slow-query log; working set vs RAM; oplog window;
     replica lag; document growth; driver pool vs server connection limit.
3. **Timeouts**: `statement_timeout`, `lock_timeout` and idle-in-transaction timeout set (Postgres);
   `maxTimeMS` on long queries (Mongo).
4. **Partitioning and archival**: partition large tables by time range or hash with aligned indexes; a
   retention policy that moves cold data out and drops old partitions in place of a bulk `DELETE`.
5. **Capacity**: project storage, IOPS, memory and connection headroom 6–12 months out from the current
   growth rate.
6. **Backup ownership**: who runs backups for this store (managed service, in-cluster, platform team). If
   the evidence does not show it, write `UNKNOWN` and what to read to settle it. A backup counts only after
   a tested restore (step 06).
7. **Rank findings** CRITICAL/HIGH/MEDIUM/LOW with impact and remediation; continue into 04–07 where a
   finding needs a design.

Done when every checklist item for the engine has a value or `UNKNOWN`, and every finding has a remediation.

## Changes to a running database
Config, failover, replication, access and index changes on prod go through
the `ai-governance-control` skill: dry-run first, approval before execute.
Each proposed change lists the command/config, its risk, and how to validate it.
