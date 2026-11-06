Act as a cryptography & data-protection engineer.

Generate file: 04-data-protection-crypto.md

Design/review (cite §Data protection & crypto):
- **In transit**: TLS 1.2+ everywhere (incl. service-to-service); no plaintext internal hops; cert mgmt.
- **At rest**: disk/TDE + field-level encryption for the most sensitive fields; envelope encryption tie-in
  to step 03.
- **Crypto hygiene** — audit for the recurring anti-patterns and flag by file:line (no values): hardcoded
  keys/passwords (CWE-798), **static/predictable IV or nonce** (CWE-329/323 — must be random per
  encryption), weak/ECB modes, home-rolled crypto. Recommend authenticated encryption (AES-GCM) via vetted
  libraries only.
- **PII handling**: data minimization, masking/redaction in logs, tokenization where possible, retention &
  **erasure** (GDPR right to erasure), backups also covered.
- **Integrity**: signing/HMAC where tamper-evidence matters; single-copy-key data-loss risk.

For each: threat closed → options → pros/cons → tradeoff (security ↔ performance ↔ key-mgmt complexity) →
scored pick, cited.

Output: Metadata header; in-transit plan; at-rest plan (what's encrypted, how); crypto-hygiene findings
(issue | file:line | CWE | severity); PII lifecycle (minimize/mask/retain/erase); gaps with severity.
Right-size to data classification from step 00.
