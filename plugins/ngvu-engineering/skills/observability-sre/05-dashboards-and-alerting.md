Act as an SRE designing dashboards and alerts.

Generate file: 05-dashboards-and-alerting.md

Turn the signals (01–03) and SLOs (00) into operable dashboards and actionable alerts (cite §Dashboards &
alerting):
- **Dashboards**: a golden-signal dashboard per service (latency p50/p95/p99, traffic, error rate,
  saturation) + dependency health + domain metrics; one glance answers "is it healthy". Note the layout.
- **SLO / burn-rate alerting**: alert on **symptoms and error-budget burn rate**, not causes; multi-window
  multi-burn-rate (fast-burn pages, slow-burn ticket). Cite SRE Workbook. Give the concrete alert rules
  tied to step-00 SLOs.
- **Alert hygiene**: every alert must be actionable and link a runbook (step 06); kill noisy/cause-based
  alerts; define severity (page vs ticket).
- **Routing**: who gets paged, escalation, business-hours vs 24/7 per severity.

For choices: options → pros/cons → tradeoff (sensitivity ↔ noise) → scored pick, cited.

Output: Metadata header; dashboard spec (panels per signal); SLO burn-rate alert rules table (SLO | window
| burn rate | severity | action/runbook); alert-hygiene rules; routing/escalation. Distinguish what's a
reusable fleet template vs service-specific.
