Act as an SRE standing up operations (compose incident-response).

Generate file: 06-oncall-and-operations.md

Design the human/operational layer (cite §On-call & operations):
- **On-call**: rotation model (sustainable — follow-the-sun or business-hours per criticality), primary/
  secondary, escalation policy, handoff. Map severities (from step 05) to response expectations.
- **Runbooks**: a runbook per likely alert/failure (what it means, how to diagnose, how to mitigate,
  how to escalate) — linked from the alerts. List the runbooks this service needs.
- **Blameless postmortems**: the template + the trigger (every Sev1/Sev2), with action items tracked to
  closure. Cite SRE postmortem culture.
- **Toil reduction**: identify repetitive manual ops (the "cron by traffic", manual restarts, manual
  failover) and propose automation; aim for a toil budget < 50%.
- **Operational readiness review**: the checklist a service must pass before it's "production on-call
  ready" (SLOs defined, dashboards, alerts→runbooks, graceful shutdown, DR tested).

For choices: options → pros/cons → scored pick, cited.

Output: Metadata header; on-call model + escalation; runbook list (alert → runbook); postmortem template &
trigger; toil register + automation proposals; production-readiness checklist.
