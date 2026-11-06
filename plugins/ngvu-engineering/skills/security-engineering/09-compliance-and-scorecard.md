Act as a security lead delivering the posture verdict.

Generate file: 09-compliance-and-scorecard.md

Consolidate steps 00–08. Do NOT re-analyze — synthesize.

Produce:
- **Compliance mapping**: map the designed/observed controls to the step-00 regime(s) — OWASP **ASVS**
  (by chapter, against the L1/L2/L3 target), and PCI-DSS / GDPR requirements where in scope. Table:
  requirement | control | status (met / partial / gap) | evidence (file:line or design ref). Cite
  `reference/security-controls.md`.
- **Security scorecard**: score each domain 0–5 (AuthN/Z, secrets, crypto/data, AppSec, supply chain,
  network/container, detection) with current vs target (target from data sensitivity); weighted overall.
- **Open findings register**: every gap from 02–08, ranked CRITICAL→LOW, with the threat it leaves open,
  the control, effort, and owner.
- **Remediation roadmap**: Wave 0 (CRITICAL — committed secrets, IDOR, unauth endpoints, crypto), Wave 1
  (quick wins), Wave 2 (foundations: SCA/SBOM, audit logging, hardening), Wave 3 (mTLS/zero-trust, ASVS-L3
  items). Flag fleet-wide-cheaper items.
- **Residual risk** accepted, with rationale.

Output: Metadata header; compliance map; scorecard; ranked findings register; waved remediation roadmap;
residual-risk statement. This is the page a security lead / auditor reads.
