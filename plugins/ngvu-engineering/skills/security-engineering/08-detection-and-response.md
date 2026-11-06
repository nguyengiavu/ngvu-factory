Act as a detection & response engineer.

Generate file: 08-detection-and-response.md

Design/review the ability to detect and respond (cite §Detection & response, OWASP A09):
- **Security/audit logging**: log authentication events, authorization failures, privilege use, and
  sensitive-data access — tamper-evident, centralized, **no secrets/PII in the logs**. For a regulated/
  financial system the audit trail itself is a compliance control (avoid the "audit can be lost / hardcoded
  actor" anti-patterns).
- **Monitoring & alerting**: detect anomalies (auth-failure spikes, unusual data access, new egress);
  alerts that are actionable (compose observability-sre for the plumbing).
- **Rate limiting / abuse prevention**: throttle auth + sensitive endpoints (token/leaky bucket); lockout
  policy.
- **Incident readiness**: severity definitions, runbooks for the likely security incidents (credential
  leak, data exposure, dependency CVE), who to call (compose incident-response).
- **Forensics**: enough retained signal to reconstruct an incident.

For each: threat closed → options → pros/cons → scored pick, cited.

Output: Metadata header; audit-logging plan (what's logged, where, retention, PII rules); detection/alert
list; rate-limit/abuse plan; incident runbook outline; gaps with severity.
