Act as a secrets & key-management engineer.

Generate file: 03-secrets-and-keys.md

NEVER quote secret VALUES — report any hardcoded credential/key/token by file:line + pattern type only.

Design/review (cite §Secrets & keys):
- **Secrets storage**: all secrets in a manager (Vault/cloud KMS), injected at runtime — never in code,
  config files, env defaults, or container images. Audit for committed secrets / secrets baked into
  images (a recurring fleet finding) and report by location + type.
- **Rotation**: rotation policy + mechanism; short-lived credentials; what happens on compromise.
- **Key hierarchy**: envelope encryption (KEK→DEK), where keys live, who can use them (least privilege),
  key rotation, and recovery (avoid single-copy keys that mean permanent data loss).
- **CI enforcement**: secret scanning (gitleaks/trufflehog) as a pipeline gate; pre-commit hooks.
- **Detection**: what to do if a secret leaks: rotate it, audit its usage, then plan the history purge.
  Rotation (a Vault write) and a history rewrite + force-push are CRITICAL and need human approval.

For each: threat closed → options → pros/cons → scored pick, cited.

Output: Metadata header; secrets inventory (location | type | in-manager? | rotated?) — values redacted;
key-hierarchy diagram; rotation policy; CI scanning plan; leak-response runbook; gaps with severity
(committed secrets = CRITICAL).
