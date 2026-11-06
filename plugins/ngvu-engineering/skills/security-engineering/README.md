# security-engineering

Engineer security by design and harden what exists — threat-model first, then design/review every control
layer, ending with a compliance mapping + scored posture + remediation roadmap. See `SKILL.md`.

## Produces
A `security-engineering/` folder of 10 reports (00–09): scope & assets → threat model (STRIDE) →
authN/authZ (incl. IDOR & tenant isolation) → secrets & keys → data-protection crypto → AppSec (OWASP) →
supply chain → network & container → detection & response → compliance mapping & scored remediation.

## The promise
**Threat-first**: every control names the threat it stops (linked to the threat model). Options →
pros/cons → tradeoff → scored decision → cited standard (`reference/security-controls.md`: OWASP ASVS/Top
10, CWE, NIST, CIS). Severity by exploitability x impact; right-sized to data sensitivity. **Never quotes
secret values** — committed secrets reported by file:line + pattern type.

## Relationship to other skills
- For reviewing only the pending diff → built-in **/security-review**. Full multi-aspect audit →
  **system-analysis**. Container/network hardening detail → **cloud-infrastructure**. Audit-log plumbing →
  **observability-sre**. Incident handling → **incident-response**.

## Output convention
`output/<project>/security-engineering/`.
