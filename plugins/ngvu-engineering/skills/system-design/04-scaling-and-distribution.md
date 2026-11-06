Act as a distributed-systems engineer planning how the design scales.

Generate file: 04-scaling-and-distribution.md

Anchored to the step-01 capacity numbers, address (only what the scale warrants):
- **Stateless app tier + horizontal scaling**: what state must move out, how replicas scale.
- **Load balancing**: L4 vs L7, algorithm (round-robin / least-conn / consistent-hash) with tradeoff.
- **Partitioning/sharding** (if the numbers demand it): key choice (range/hash/directory), hot-spot
  avoidance, rebalancing cost. If NOT needed, say so explicitly and why (right-sizing).
- **Replication**: leader-follower / multi-leader / leaderless; replication lag, read-your-writes.
- **Read scaling**: read replicas, caching (forward-ref to step 05).

For each mechanism: options → pros/cons → tradeoff axis (e.g. throughput ↔ consistency, cost ↔ latency) →
scored pick weighted by step-00 NFRs, cited from `reference/building-blocks.md` (DDIA ch.5/6, consistent
hashing, etc.).

Output: Metadata header; one subsection per mechanism with its decision matrix; a "what we deliberately
did NOT add and why" note. Quantify against step-01 numbers.
