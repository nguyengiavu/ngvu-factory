# Observability & SRE practices (cite from here)

Cite when recommending. Mark others `[unverified]`. Anchors: **Google SRE Book** & **SRE Workbook**
(O'Reilly 2016/2018), **OpenTelemetry docs** (opentelemetry.io), **Observability Engineering** (Majors,
Fong-Jones, Miranda, O'Reilly 2022), **Prometheus/Grafana docs**.

## SLOs
- **SLI** = a measured quality (e.g. request latency, success rate); **SLO** = target for an SLI over a
  window; **error budget** = 1 − SLO, spend it on change velocity. Source: SRE Book ch.4; SRE Workbook
  "Implementing SLOs".
- Derive SLIs from **user journeys** ("can the user do X fast and correctly"), not from what's easy to
  measure. Source: SRE Workbook.

## Metrics — the four golden signals + method
- **Four golden signals**: latency, traffic, errors, saturation. Source: SRE Book ch.6 "Monitoring
  Distributed Systems".
- **RED** (Rate, Errors, Duration) for request-driven services; **USE** (Utilization, Saturation, Errors)
  for resources. Source: Tom Wilkie (RED); Brendan Gregg (USE).
- **Cardinality discipline**: labels multiply series — avoid unbounded labels (user id, request id) on
  metrics; put high-cardinality data in traces/logs. Source: Prometheus best practices.
- Instrumentation: OpenTelemetry metrics, or platform-native (Micrometer, MicroProfile Metrics).

## Tracing
- **Distributed tracing** (Dapper lineage): propagate context (`traceparent`/W3C Trace Context) across
  every hop; spans must be **started AND ended/exported** (a started-never-ended span is a leak/dead
  instrumentation). Source: Google *Dapper* (2010); OpenTelemetry docs; W3C Trace Context.
- **OpenTelemetry** is the vendor-neutral standard; **OpenCensus/OpenTracing are deprecated** → migrate.
  Source: opentelemetry.io migration guide.
- **Sampling**: head vs tail sampling — tradeoff completeness ↔ cost/volume. Source: OTel sampling docs.

## Logging
- **Structured (JSON) logs** with **correlation/trace IDs** so logs join traces; consistent levels; no
  secrets/PII; sane retention. Source: Observability Engineering; OWASP Logging Cheat Sheet (for PII).
- Logs are for high-cardinality detail and forensics; metrics for trends/alerts; traces for causality.
  Source: Observability Engineering (three pillars + events).

## Health & lifecycle
- **Liveness** = "restart me if this fails" (process health only — NOT dependency checks, or you cascade
  restarts); **Readiness** = "send me traffic only if deps are reachable"; **Startup** = slow-start grace.
  An always-200 liveness/readiness is a common anti-pattern. Source: Kubernetes "Configure Liveness,
  Readiness and Startup Probes".
- **Graceful shutdown**: drain in-flight on SIGTERM before exit. Source: Kubernetes pod lifecycle.

## Dashboards & alerting
- **Alert on symptoms / SLO burn rate, not causes**; every alert must be actionable (page-worthy) or it's
  noise. Multi-window multi-burn-rate alerts. Source: SRE Workbook "Alerting on SLOs".
- Dashboards: golden signals per service + dependency health; one glance = is it healthy. Source: SRE Book.

## On-call & operations
- **Blameless postmortems** for every significant incident; **on-call** hygiene (sustainable rotation);
  **toil budget < 50%** of SRE time; runbooks linked from alerts. Source: SRE Book chs. "On-Call",
  "Postmortem Culture", "Eliminating Toil".

## Right-sizing
- Aim for enough signal to cut MTTR and prove SLOs — not a metric/label explosion (cardinality = cost).
- The biggest leverage is usually **fleet-wide**: a shared base image/agent (OTel auto-instrumentation,
  JSON logging, golden-signal HTTP metrics, health subsystem) instruments many services at once. Per-
  service work = the domain metrics and SLOs only the service knows.
