Act as an identity & access engineer.

Generate file: 02-authn-authz.md

Design/review authentication & authorization to close the relevant step-01 threats (cite §AuthN/AuthZ):
- **AuthN**: how callers authenticate (OIDC/JWT/mTLS); token validation done correctly (signature, iss,
  aud, exp) and **fail-closed** (a validation error must deny, not allow); token lifetime/refresh. Flag any
  fail-open path.
- **AuthZ model**: RBAC vs ABAC (scored tradeoff: simplicity ↔ granularity); enforced per-request, not
  just at the edge.
- **Object-level authorization (IDOR)**: every access to a specific object must verify the caller owns/may
  access THAT object — not merely that they're authenticated. This is a top recurring gap; cite OWASP BOLA
  / CWE-639. Show the check.
- **Multi-tenant isolation**: every query scoped by tenant AND sub-tenant (company); describe how cross-
  tenant/cross-company access is prevented AND how it's tested.
- **Sensitive operations**: step-up auth / re-auth for high-value actions.

For each: threat closed → options → pros/cons → scored pick, cited. When reviewing, cite file:line.

Output: Metadata header; authN design (with fail-closed note); authZ model + matrix; IDOR control with
example; tenant-isolation rule + test approach; gaps with severity.
