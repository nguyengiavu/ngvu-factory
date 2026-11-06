Act as a Security Architect benchmarking against zero-trust hyperscaler practice.

Generate file:
04-security-zerotrust.md

Benchmark against `reference/bigtech-patterns.md` §04 (Google BeyondCorp zero-trust; secrets
management/rotation via Vault/KMS/Workload Identity; mTLS / SPIFFE; supply-chain SLSA/SBOM/signing; OWASP
ASVS & Top 10; least privilege + short-lived credentials + audit logging).

NEVER quote secret VALUES — report any hardcoded credential/key/token by file:line + pattern type only.

Examine (cite file:line / config):
- **Secrets hygiene**: committed secrets, keys baked into images, secrets as env defaults; rotation;
  Vault/KMS/Workload Identity usage.
- **AuthN/AuthZ**: token validation correctness, fail-open vs fail-closed, `@PermitAll`/unauthenticated
  endpoints, object-level authorization (IDOR), tenant + intra-tenant isolation.
- **Transport & identity**: TLS/mTLS between services, network trust assumptions vs zero-trust.
- **Input & crypto**: injection/XXE, file-upload safety (zip-slip/zip-bomb, AV scanning), crypto choices
  (hardcoded passwords, static IV, weak modes) — report patterns, not values.
- **Supply chain**: dependency/CVE scanning, SBOM, signed artifacts, base-image provenance.

For EACH gap: (1) current state file:line + pattern type; (2) target practice + source (§04); (3) why it
matters — the attack/breach scenario and business/compliance impact, with severity (secrets/keys leaks
are typically CRITICAL); (4) recommended target level + action. For financial/PII data, justify targets
of 4–5.

Output: Metadata header (current/target level), gap list (CRITICAL first), comparison table, Missing
Information (e.g. external auth lib internals, prod secret injection). Score 0–5 (Current / Target / Gap).
