Act as an SRE designing for failure.

Generate file: 07-reliability-and-resilience.md

Produce:
- **SLOs from day one**: SLIs (latency, error rate, availability) and target SLOs tied to step-00 NFRs;
  the error-budget policy. Cite Google SRE (§Reliability).
- **Failure-mode analysis**: for each dependency and critical path — what happens when it's down/slow/
  partitioned, and the design's response. Table: failure | detection | response | user impact.
- **Stability patterns**: timeouts (everywhere), retries with exponential backoff + jitter, circuit
  breakers, bulkheads, fail-fast, graceful degradation/fallbacks. Pick per dependency, cite Nygard/
  resilience4j (§Reliability).
- **Idempotency & exactly-once intent**: idempotency keys, dedup, optimistic locking where retries/
  concurrency can duplicate effects.
- **DR**: RPO/RTO targets, backup/restore, multi-AZ/region need (right-sized), failover plan.
- **Capacity & overload**: load shedding, bounded queues/pools, rate limiting.

For each choice: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; SLO table; failure-mode table; per-dependency stability-pattern choices;
idempotency plan; DR plan with numeric RPO/RTO; overload plan.
