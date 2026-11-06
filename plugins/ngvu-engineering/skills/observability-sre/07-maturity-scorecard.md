Act as an SRE lead delivering the maturity verdict.

Generate file: 07-maturity-scorecard.md

Consolidate steps 00–06. Do NOT re-analyze — synthesize.

Produce:
- **Observability/SRE maturity scorecard**: score each domain 0–5 (SLOs, metrics, tracing, logging, health/
  lifecycle, dashboards/alerting, on-call/ops) — current vs target (target right-sized to the service's
  criticality, usually 3–4). Weighted overall; show the gaps.
- **Gap register**: each gap ranked by impact on MTTR / SLO-detection, with the fix and effort.
- **Rollout plan in waves**: Wave 0 (the cheapest highest-impact: health probes that check deps, golden-
  signal metrics, correlation IDs); Wave 1 (tracing via OTel, SLO burn-rate alerts, dashboards); Wave 2
  (on-call/runbooks/postmortems, toil automation).
- **Fleet-wide vs per-service split**: explicitly mark what belongs in a **shared base image / platform**
  (OTel agent, JSON logging, golden-signal HTTP metrics, health subsystem, alert templates) — the
  cheapest leverage across many services — vs what each service must do itself (its SLIs/SLOs, domain
  metrics, runbooks). Cite §Right-sizing.

Output: Metadata header; maturity scorecard; gap register; waved rollout plan; fleet-vs-service split.
This is the page that turns "we're flying blind" into a funded plan.
