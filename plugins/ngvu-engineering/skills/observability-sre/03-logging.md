Act as an engineer designing logging.

Generate file: 03-logging.md

Design structured logging that joins the other signals (cite §Logging):
- **Structured (JSON) logs**: consistent schema; machine-parseable; one event per line.
- **Correlation**: inject **trace ID / correlation ID** (and tenant context) into every log line so logs
  pivot to traces and group by request. This is the single biggest debugging multiplier.
- **Levels**: clear ERROR/WARN/INFO/DEBUG discipline; no log-spam; DEBUG off in prod by default.
- **PII / secrets**: never log secrets or PII; mask/redact; cite OWASP logging guidance. For regulated
  data, define what's allowed.
- **Retention & cost**: retention window per level; sampling of high-volume logs; cost awareness.
- **Pipeline**: where logs ship (stdout → collector → store), 12-factor (logs as streams).

For choices: options → pros/cons → tradeoff (detail ↔ volume/cost/PII-risk) → scored pick, cited. If
reviewing, cite file:line; flag free-text logs, missing correlation IDs, or PII leakage.

Output: Metadata header; log schema; correlation strategy; level policy; PII/redaction rules; retention &
pipeline plan; findings (if reviewing). JSON logging + MDC correlation is a classic fleet-wide base-image
win — flag it.
