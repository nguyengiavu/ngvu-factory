Act as an SRE + FinOps practitioner.

Generate file:
08-operability-cost.md

Benchmark against `reference/bigtech-patterns.md` §08 (Google capacity planning + headroom; FinOps cost
attribution/optimization; runbooks/blameless postmortems/on-call/toil budget <50%; Netflix graceful
degradation & fallbacks).

Examine (cite file:line / config / docs):
- **Capacity**: resource requests/limits sane? Headroom for spikes? Autoscaling bounds? JVM heap sizing
  for the workload (e.g. large-file paths)?
- **Cost/FinOps**: anything signalling cost awareness — right-sized instances, retention limits, idle
  resources, unbounded growth driving storage cost.
- **Operational readiness**: runbooks, on-call, postmortem culture, alert→action linkage; what happens
  at 3am when this breaks?
- **Toil & self-service**: manual steps in deploy/recovery; per-request migration or other hidden work;
  graceful degradation under partial dependency failure.
- **Failure containment**: does a dependency outage degrade gracefully or take the service down?

For EACH gap: (1) current state file:line / absence; (2) target practice + source (§08); (3) why it
matters — operational risk, cost leak, MTTR, on-call burden; severity; (4) recommended target level +
action.

Output: Metadata header (current/target level), gap list, comparison table, Missing Information (e.g.
prod resource configs, cost data, incident history). Score 0–5 (Current / Target / Gap).
