Act as an SRE specializing in observability.

Generate file:
06-observability.md

Benchmark against `reference/bigtech-patterns.md` §06 (Google four golden signals; three pillars +
OpenTelemetry; Dapper distributed tracing; SLO/burn-rate alerting; structured logging + high-cardinality
events).

Examine (cite file:line / config):
- **Metrics**: are the four golden signals (latency, traffic, errors, saturation) emitted? Domain
  metrics for key flows? Any metrics at all, or only logs?
- **Tracing**: distributed tracing present and wired (exporter/sampler configured), or library-present-
  but-dead (e.g. spans started never finished, EOL tracer)? Trace propagation across the call chain?
- **Logging**: structured vs free-text; correlation/trace IDs; PII in logs; log levels.
- **Health**: liveness/readiness that actually check dependencies, or always-200 stubs?
- **Alerting**: symptom/SLO-based alerting and dashboards, or none / cause-based only?

For EACH gap: (1) current state file:line; (2) target practice + source (§06); (3) why it matters — what
you cannot see during an incident, MTTR impact; severity; (4) recommended target level + action. Note
where instrumentation is best done fleet-wide (shared base image / agent) rather than per-service.

Output: Metadata header (current/target level), gap list, comparison table, Missing Information (e.g.
external dashboards/alert policies not in repo). Score 0–5 (Current / Target / Gap).
