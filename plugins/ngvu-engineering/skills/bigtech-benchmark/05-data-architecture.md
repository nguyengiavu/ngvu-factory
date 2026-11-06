Act as a Principal Data/Distributed-Systems Architect.

Generate file:
05-data-architecture.md

Benchmark against `reference/bigtech-patterns.md` §05 (polyglot/purpose-built storage; Dynamo tunable
consistency; Kafka/log-as-source-of-truth event streaming; CQRS/materialized read models; online
schema evolution expand/contract; partitioning/TTL/archival).

Examine (cite file:line / config / schema / migrations):
- **Storage fit**: is the chosen store right for the access pattern? Single bottleneck vs partitioned?
- **Consistency model**: transactions vs eventual consistency; dual-write risks; outbox; cross-entity
  invariants enforced in app code only.
- **Indexes & access paths**: missing indexes, unbounded scans, missing pagination (cross-check the
  performance pillar).
- **Read scaling**: materialized/denormalized read models, CQRS, caching of derived data; correctness of
  cascade/invalidation.
- **Schema evolution**: migration strategy (online vs blocking), versioning, backfills, rollback.
- **Lifecycle**: unbounded-growth tables/collections, TTL/retention/archival, especially for sensitive
  data.

For EACH gap: (1) current state file:line; (2) target practice + source (§05); (3) why it matters — data
loss / staleness / scaling wall / compliance retention; severity; (4) recommended target level + action.

Output: Metadata header (current/target level), gap list, comparison table, Missing Information (e.g.
physical storage internals behind an abstraction service, index inventory). Score 0–5 (Current/Target/Gap).
