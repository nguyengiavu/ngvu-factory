Act as a DBA reasoning about transactions and consistency.

Generate file: 03-transactions-and-consistency.md

For the write paths from step 01–02, specify the transaction & consistency design (cite engine-comparison
§Transactions):
- **Isolation level** per critical operation and WHY: PostgreSQL (Read Committed / Repeatable Read /
  Serializable-SSI); MS SQL Server (incl. **RCSI/Snapshot** to avoid reader/writer blocking); MongoDB
  (single-doc atomicity; multi-doc ACID txns + their cost; **read/write concern** `w:majority` etc.).
- **Concurrency hazards**: lost update, write skew, phantom, TOCTOU — which can occur here and the guard
  (optimistic locking / `@Version`, unique constraints, `SELECT FOR UPDATE`, appropriate isolation).
- **Cross-store / cross-service consistency**: avoid 2PC; use **saga + outbox + idempotency**; state where
  you accept eventual consistency and the user-visible effect. Cite DDIA ch.7/9, microservices.io Saga.
- **Durability**: fsync/commit guarantees, write concern, replication acknowledgement.

For each choice: options → pros/cons → tradeoff axis (consistency ↔ throughput ↔ latency) → scored pick,
cited. Show an example (e.g. the isolation level + the constraint that together prevent a duplicate).

Output: Metadata header; per-operation isolation table; concurrency-hazard → guard table; cross-store
consistency plan; durability settings. Be explicit about every place correctness depends on the choice.
