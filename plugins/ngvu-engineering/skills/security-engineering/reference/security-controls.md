# Security controls & sources (cite from here)

Cite when recommending a control. Mark others `[unverified]`. Anchor standards: **OWASP ASVS v4**, **OWASP
Top 10 (2021)**, **OWASP Cheat Sheet Series**, **CWE**, **NIST SP 800-53/63**, **MITRE ATT&CK**, vendor docs.

## Threat modeling
- **STRIDE** (Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation). Source: Microsoft SDL;
  Shostack, *Threat Modeling*. **Attack trees / abuse cases** to enumerate paths. Source: Schneier.
- **Trust boundaries**: model where untrusted data crosses into trusted code; validate at the boundary.

## AuthN / AuthZ
- **AuthN**: OIDC/OAuth2, JWT validation (verify signature, `iss`, `aud`, `exp`; fail **closed**), mTLS
  for service identity, short-lived tokens. Source: OWASP ASVS V2/V3; OAuth2 BCP (RFC 8725 JWT BCP).
- **AuthZ**: enforce per-request; **object-level authorization** to prevent **IDOR** (check the caller owns
  the object, not just that they're authenticated). Source: OWASP API Security Top 10 (API1 BOLA);
  CWE-639. **Multi-tenant**: every query scoped by tenant AND sub-tenant; test cross-tenant access.
- **RBAC vs ABAC**: RBAC simple/coarse; ABAC fine-grained/contextual but complex. Tradeoff: simplicity ↔
  granularity. Source: NIST RBAC; OWASP Access Control Cheat Sheet.

## Secrets & keys
- **Never commit secrets / bake into images**; store in Vault/KMS, inject at runtime, **rotate**. Source:
  OWASP Secrets Management Cheat Sheet; CWE-798 (hardcoded credentials). Add CI secret scanning (gitleaks).
- **Key hierarchy / envelope encryption** (KEK → DEK); least privilege on keys. Source: Google/AWS KMS docs.

## Data protection & crypto
- **TLS 1.2+ in transit; encryption at rest** (TDE / disk / field-level for the most sensitive). Source:
  OWASP Transport Layer & Cryptographic Storage Cheat Sheets.
- **Crypto hygiene**: no hardcoded keys/passwords, **random IV/nonce per encryption** (static IV in
  CBC/GCM is a vuln — CWE-329/CWE-323), authenticated encryption (AES-GCM), vetted libraries only.
  Source: OWASP Cryptographic Storage Cheat Sheet.
- **PII**: classify, minimize, mask in logs, define retention/erasure (GDPR right to erasure). Source:
  GDPR Art.5/17; OWASP Logging Cheat Sheet.

## AppSec (OWASP Top 10 / ASVS)
- **Injection** (SQL/NoSQL/cmd): parameterized queries / safe APIs. CWE-89/943. **SSRF**: allow-list
  outbound, block metadata IPs (CWE-918, OWASP A10). **XXE**: disable external entities (CWE-611).
- **Insecure deserialization**: avoid native deser of untrusted data (CWE-502).
- **File upload**: validate type by content (not extension), enforce size limits, scan for malware, prevent
  **zip-slip** (path traversal on extract, CWE-22) and **zip-bomb** (resource limits). Source: OWASP File
  Upload Cheat Sheet.
- **Input validation & output encoding** (XSS — CWE-79); **CSRF** tokens; **CORS** never `*` with
  credentials. Source: OWASP Top 10 A03/A05; CORS Cheat Sheet.

## Supply chain
- **SCA / CVE scanning** of dependencies (OWASP Dependency-Check, Trivy, Snyk); **SBOM** (CycloneDX/SPDX);
  **signed artifacts** (Sigstore/cosign); **SLSA** levels; pin/digest base images. Source: slsa.dev; OWASP
  A06 (Vulnerable & Outdated Components).

## Network & container
- **Zero-trust** (authenticate every request, don't trust the network). Source: Google BeyondCorp; NIST
  SP 800-207. **mTLS / service mesh** for service identity. Source: SPIFFE/SPIRE; Istio.
- **Container hardening**: non-root user, read-only root FS, drop Linux capabilities, no privileged, no
  debug ports (JDWP/mgmt) exposed, minimal base image. Source: CIS Docker/Kubernetes Benchmarks; NSA/CISA
  Kubernetes Hardening Guide.

## Detection & response
- **Security/audit logging** of authn, authz failures, sensitive access — tamper-evident, no secrets/PII;
  centralized; alerting on anomalies. Source: OWASP Logging Cheat Sheet; OWASP A09 (Logging & Monitoring
  Failures). **Incident readiness**: runbooks, on-call (compose incident-response).

## Compliance mapping
- **OWASP ASVS** levels: L1 (basic), L2 (most apps — default target), L3 (high-value/financial). Source:
  OWASP ASVS. **PCI-DSS** if card data; **GDPR** for EU PII (lawful basis, minimization, erasure, breach
  notice); **SOC 2** trust criteria. Map controls → requirement IDs.

## Right-sizing
- Defense in depth, but proportional to data sensitivity and threat. Financial/PII/legal → ASVS L2–L3,
  encryption + RLS + audit. Don't bolt on a WAF/mesh/HSM where the threat model doesn't justify it — but
  never skip the basics (no committed secrets, object-level authz, input validation, TLS).
