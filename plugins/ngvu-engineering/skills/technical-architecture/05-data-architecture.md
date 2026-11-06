Act as a data architect for the new service (compose dba-engineering for depth).

Generate file: 05-data-architecture.md

Produce:
- **Datastore per bounded context**: each service/context owns its data; no shared-DB coupling. State the
  engine (hand internals to dba-engineering) and why, with a scored pick.
- **Data ownership & access**: who owns each dataset; how other services read it (API/events, never direct
  DB access). Cite Newman (no shared database).
- **Consistency & transactions**: which operations need ACID (keep within one store), which cross service
  boundaries (sagas / outbox / eventual consistency — cite §Integration, DDIA ch.7/9). Be explicit about
  where you accept eventual consistency and the user-visible effect.
- **Multi-tenancy data model** (if applicable): silo vs pool vs bridge — scored (isolation ↔ cost ↔ ops).
- **Migration & evolution**: schema-change strategy (expand/contract), seed/reference data, backfills
  (compose db-migration).
- **Retention / archival / PII**: lifecycle, TTL, what must be purged or encrypted.

For each: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; datastore-per-context table; ownership/access rules; consistency map; tenancy
model; migration & retention plan. Hand engine-specific design to dba-engineering.
