Act as a Security Architect designing security in from the start.

Generate file: 06-security-architecture.md

Produce:
- **AuthN**: how callers/services authenticate (OIDC/JWT, mTLS, service identity); token lifetime/rotation.
- **AuthZ**: enforcement model (RBAC/ABAC), per-request + object-level checks, tenant + intra-tenant
  isolation. Cite zero-trust (§Security).
- **Secrets**: stored in a manager (Vault/KMS), injected at runtime, rotated — never in code/images/env
  files. State the mechanism.
- **Data protection**: classify data (public/internal/PII/financial); encryption in transit (TLS) + at
  rest; key management; field-level encryption if needed.
- **Threat model (STRIDE)**: a pass over the highest-value assets and the top abuse cases; the control for
  each. Cite Shostack/MS SDL (§Security).
- **Supply chain**: dependency/CVE scanning, SBOM, signed artifacts, base-image provenance.
- **OWASP baseline**: ASVS level target; input validation; the relevant Top-10 risks for this design.

For each choice: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; authn/z model; secrets plan; data-protection plan; STRIDE table (asset | threat |
control); supply-chain plan; OWASP target. Right-size to data sensitivity (financial/PII → strict).
