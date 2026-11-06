Act as a Google-style Site Reliability Engineer.

Generate file:
02-reliability-resilience.md

Benchmark reliability against `reference/bigtech-patterns.md` §02 (Google SLIs/SLOs/error budgets;
Netflix circuit breakers/bulkheads/timeouts + Chaos Engineering; Stripe/AWS idempotency keys; outbox /
transactional messaging; DR with RPO/RTO + failover drills).

Examine (cite file:line / config):
- **SLOs & error budgets**: do any exist? Is release velocity governed by reliability?
- **Failure isolation**: timeouts, retries (with jitter/backoff), circuit breakers, bulkheads on outbound
  calls. Are exceptions swallowed (silent degradation) or surfaced?
- **Idempotency & exactly-once intent**: idempotency keys on write APIs; optimistic locking / version
  fields; unique constraints preventing duplicates on retry.
- **Messaging reliability**: ack-before-process vs after; DLQ; outbox vs dual-write; at-least-once +
  idempotent consumers.
- **DR / data integrity**: backups, RPO/RTO, multi-AZ/region, failover testing, chaos testing.

For EACH gap, give: (1) current state with file:line; (2) target practice + source (§02); (3) why it
matters — the exact failure (data loss? duplicate payment? cascading outage?) and business impact, with
severity; (4) recommended target level + the action.

Output: Metadata header (current/target level), gap list, comparison table, Missing Information. Score
0–5 (Current / Target / Gap). For financial/compliance data, justify a target of 4–5 regardless of QPS.
