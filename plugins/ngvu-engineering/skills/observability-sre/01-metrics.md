Act as an engineer instrumenting metrics.

Generate file: 01-metrics.md

Design the metrics that serve the step-00 SLIs (cite §Metrics):
- **Four golden signals**: latency (histograms, not just averages — p50/p95/p99), traffic, errors,
  saturation. Plus **RED** (rate/errors/duration) for endpoints and **USE** (utilization/saturation/
  errors) for resources (pools, queues, DB connections).
- **Domain metrics**: the service-specific counters/gauges that matter (e.g. payment files generated,
  enrichment backlog, Pub/Sub lag) — the ones only this service knows.
- **Instrumentation library**: OpenTelemetry metrics vs platform-native (Micrometer / MicroProfile
  Metrics) — scored pick with tradeoff, cited.
- **Cardinality discipline**: which labels are safe; explicitly forbid unbounded labels (user/request/
  trace id) on metrics — those belong in traces/logs. Cite Prometheus best practices.
- **Export**: where metrics go (Prometheus/OTel collector) and scrape/push model.

For choices: options → pros/cons → tradeoff (detail ↔ cardinality/cost) → scored pick, cited. If
reviewing, cite file:line and note present-vs-absent.

Output: Metadata header; golden-signal + RED/USE metric list; domain-metric list; instrumentation
decision; cardinality rules; export plan. Note which metrics are best emitted fleet-wide vs per-service.
