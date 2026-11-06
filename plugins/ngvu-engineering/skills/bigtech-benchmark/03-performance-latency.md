Act as a performance engineer who has tuned hyperscale services.

Generate file:
03-performance-latency.md

Benchmark against `reference/bigtech-patterns.md` §03 (Facebook memcache multi-tier caching; CDN/edge;
connection pooling/keep-alive; Dean & Barroso tail-latency; N+1 elimination, batching, pagination).

Examine (cite file:line / config):
- **Caching tiers**: client/HTTP, CDN/edge, app, distributed cache, DB query cache — what exists, TTLs,
  invalidation, stampede protection, negative-cache correctness.
- **Connection management**: keep-alive vs per-request handshakes (`Connection: close`?), pool sizing,
  timeouts on every outbound dependency.
- **Hot paths**: N+1 calls/queries, missing pagination, large in-memory buffering, per-request expensive
  object construction (parsers, contexts), serialization cost.
- **Tail latency**: p99/p999 awareness, hedging, slow-dependency blast radius.

For EACH gap: (1) current state file:line; (2) target practice + source (§03); (3) why it matters —
quantify the cost where possible (extra round-trips, handshake overhead, memory pressure) and mark
inferred magnitudes as inferred; severity; (4) recommended target level + action, ordered by impact.

Output: Metadata header (current/target level), bottlenecks ranked by impact, comparison table, Missing
Information (note if no profiler/load-test data is available). Score 0–5 (Current / Target / Gap).
