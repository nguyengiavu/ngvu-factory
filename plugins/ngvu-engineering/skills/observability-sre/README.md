# observability-sre

Make a system observable and operable to SRE standards — SLOs, metrics, tracing, logging, health,
dashboards/alerting, on-call — ending with a scored maturity report and a fleet-wide rollout. See `SKILL.md`.

## Produces
An `observability-sre/` folder of 8 reports (00–07): SLOs & signals → metrics (golden signals/RED/USE) →
tracing (OpenTelemetry) → logging (structured + correlation IDs) → health & lifecycle → dashboards &
SLO burn-rate alerting → on-call & operations → maturity scorecard + rollout.

## The promise
**Symptom-first**: instrument what users feel (SLIs), alert on SLO burn rate not causes. Options →
pros/cons → tradeoff → scored decision → cited source (`reference/observability-practices.md`: Google SRE,
OpenTelemetry, Observability Engineering). Right-sized (signal, not metric-explosion); explicitly marks
the **fleet-wide base-image wins** (OTel agent, JSON logging, golden-signal metrics) vs per-service work.

## Relationship to other skills
- A live outage now → **incident-response**. App profiling / a specific bottleneck → **performance-tuning**;
  slow query → **sql-optimization**. Probe/securityContext manifest detail → **cloud-infrastructure**.
- Designing a new service? `technical-architecture` step 08 sets observability-from-day-one; this skill is
  the deep implementation + retrofit.

## Output convention
`output/<project>/observability-sre/`.
