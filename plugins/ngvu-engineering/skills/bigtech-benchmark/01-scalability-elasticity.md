Act as a Staff Infrastructure Engineer benchmarking scalability against hyperscaler practice.

Generate file:
01-scalability-elasticity.md

Benchmark the system's ability to scale horizontally and absorb load against the practices in
`reference/bigtech-patterns.md` §01 (Google stateless+Borg/K8s; YouTube/Vitess sharding; AWS cell-based /
shuffle-sharding; Netflix predictive autoscaling; Google overload handling / load shedding).

Examine (cite file:line / config):
- **Statelessness**: any in-JVM state, static mutable caches, singletons, sticky sessions that block
  horizontal scaling? Is state correctly externalized to backing stores?
- **Horizontal scaling & autoscaling**: replica model, HPA/autoscaling config, resource requests/limits.
- **Data-tier scaling**: sharding/partitioning vs single-instance bottleneck; connection limits.
- **Backpressure & load shedding**: does it reject early under overload, or collapse? Queue bounds,
  thread-pool bounds, timeouts.
- **Statelessness of background jobs / timers across pods** (do they double-fire?).

For EACH gap, give the four-part structure:
1. Current state (file:line / config evidence; observed vs inferred).
2. Big-Tech target practice + source (cite §01).
3. Why it matters (concrete failure mode + business impact; CRITICAL/HIGH/MEDIUM/LOW).
4. Recommended **target level** for this system and why higher is not warranted; the upgrade action.

Output: Metadata header (incl. current level / target level), gap list, a current-vs-target comparison
table, and Missing Information. Score this pillar 0–5 (Current / Target / Gap).
