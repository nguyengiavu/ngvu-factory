Act as an observability-minded SRE wiring telemetry in from the start.

Generate file: 08-observability-from-day-one.md

The principle: observability is designed in, not bolted on. Specify what ships in the first deploy:
- **Metrics**: the four golden signals (latency, traffic, errors, saturation) + key domain metrics; the
  library/exporter (Micrometer/MP Metrics/OTel). Cite Google SRE (§Observability).
- **Tracing**: distributed tracing via **OpenTelemetry**, context propagation across every hop, exporter
  + sampling configured (not just on the classpath). Cite opentelemetry.io.
- **Logging**: structured (JSON), with correlation/trace IDs and tenant context; log levels; no secrets/
  PII in logs.
- **Health**: liveness vs readiness that actually check dependencies (not always-200).
- **Alerting**: SLO/burn-rate based alerts tied to step-07 SLOs; dashboards for the golden signals.
- **Fleet vs service**: note what is cheapest delivered via a shared base image/agent across the org vs
  what's service-specific.

For each: the concrete mechanism + a one-line rationale, cited. Where there's a choice, options →
pros/cons → scored pick.

Output: Metadata header; the day-one telemetry checklist (metrics/traces/logs/health/alerts); the
dashboard/alert list mapped to SLOs; the fleet-vs-service split.
