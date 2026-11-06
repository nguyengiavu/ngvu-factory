Act as a security-minded architect.

Generate file: 08-security-and-multitenancy.md

Produce:
- **AuthN / AuthZ**: how callers authenticate (tokens/mTLS), how authorization is enforced (per-request,
  object-level), token lifetime. Cite zero-trust (§Security).
- **Multi-tenancy isolation** (if applicable): silo (DB/schema per tenant) vs pool (shared, row-scoped)
  vs bridge — scored tradeoff (isolation ↔ cost/density ↔ ops), cited (AWS SaaS Lens). State how cross-
  tenant access is prevented and tested.
- **Data protection**: classify data (PII/financial/public); encryption in transit + at rest; secrets in
  a manager with rotation; key management.
- **Abuse / threat surface**: rate limiting (link step 07), input validation, common OWASP risks for this
  design; a brief STRIDE pass on the highest-value asset.
- **Auditing**: what must be logged for compliance, without logging secrets/PII.

For each choice: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; authn/z model; tenancy decision matrix; data-protection plan; threat notes;
audit requirements. Right-size to the data sensitivity from step 00 (financial/PII raises the bar).
