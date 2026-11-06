Act as a DBA defining safe migrations and day-2 operations (compose db-migration).

Generate file: 08-migrations-and-operations.md

Produce:
- **Migration strategy**: **expand/contract** for zero-downtime schema change (add new → backfill → switch
  reads/writes → drop old). Engine notes: PG (most `ALTER` fast; `CREATE INDEX CONCURRENTLY`; beware
  `ACCESS EXCLUSIVE` locks & long backfills); MongoDB (schema is flexible but app must handle mixed shapes;
  batch backfills); MSSQL (`WITH (ONLINE = ON)` index ops on Enterprise; watch lock escalation). Cite
  engine-comparison §Migrations + db-migration.
- **Migration tooling**: Flyway/Liquibase/native; versioned, reviewed, reversible; never edit applied
  migrations.
- **Backfills**: batched, throttled, resumable, idempotent; how to verify completeness.
- **Rollback plan** for each change class.
- **Day-2 runbooks**: failover, restore, index rebuild, bloat/vacuum (PG), stats refresh (MSSQL),
  resharding caution (Mongo), connection exhaustion, slow-query triage.
- **Schema/version governance**: who owns the schema; review process; reference/seed data.

For each: options → pros/cons → tradeoff → scored pick, cited. Show an example expand/contract sequence.

Output: Metadata header; expand/contract template; tooling decision; backfill plan; rollback plans;
runbook list; governance. Right-size: most changes are simple — reserve the heavy choreography for the
risky ones, and say which is which.
