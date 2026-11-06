Act as a DBA designing backup and disaster recovery.

Generate file: 06-backup-and-dr.md

Design backup + DR with NUMERIC RPO/RTO targets (cite engine-comparison §Backup):
- **PostgreSQL**: base backup (`pg_basebackup`) + **WAL archiving** → **PITR**; logical `pg_dump` for
  portability; retention schedule.
- **MongoDB**: `mongodump`/`mongorestore`, filesystem/cloud snapshots, **oplog**-based PITR (Atlas/Ops
  Manager continuous backup).
- **MS SQL Server**: **full + differential + transaction-log** chain → PITR; backup verification.

Specify: backup frequency (derived from the RPO target), storage location (offsite/cross-region),
encryption of backups, retention, and — critically — a **restore drill** cadence ("an untested backup is
a hope"). Define the DR scenarios (node loss, AZ loss, region loss, data corruption, ransomware) and the
runbook + expected RTO for each.

For each choice: options → pros/cons → tradeoff (RPO/RTO ↔ cost ↔ storage) → scored pick, cited.

Output: Metadata header; backup strategy per engine; RPO/RTO table per failure scenario; restore-drill
plan; retention & encryption policy. Right-size RPO/RTO to the data's business value (financial/legal →
tighter).
