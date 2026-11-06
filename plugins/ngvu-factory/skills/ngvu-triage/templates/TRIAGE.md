# Triage: <symptom in one line>

Date (UTC): <yyyy-mm-dd>    Triaged by: <name> with ngvu-triage    Status: draft, no ticket yet

## Signal
| Source | Service(s) | Env | First seen (UTC) | Frequency |
|---|---|---|---|---|

## Numbers (error-count.sh)
| Workload | Window | ERROR+ count | Same window one day earlier |
|---|---|---|---|

## Sanitized evidence (max 20 lines)
```
<log lines / stack frames with TOKEN_REDACTED, PII_REDACTED, TENANT_REDACTED>
```

## Location
- `<repo>/<path>:<line>` - why this is the place (evidence class, confidence)

## Hypotheses
1. <hypothesis> - evidence class, confidence, how to confirm

## Owner
`<repo>`: owner `<team>` (from catalog-info.yaml)

## Jira draft (paste by hand)
**Summary:** <service>: <symptom>
**Type:** Bug    **Suggested priority:** <with one-line reason>
**Description:**
- What happens: ...
- Since: ... (env, first seen)
- Impact: ... (no tenant names)
- Evidence: counts above, sanitized excerpt, location
**Acceptance criteria (proposal, to be confirmed by PO):**
- ...

## Next
Create the ticket, then run ngvu-ticket-investigation with the new VUNG key and this file as input.
