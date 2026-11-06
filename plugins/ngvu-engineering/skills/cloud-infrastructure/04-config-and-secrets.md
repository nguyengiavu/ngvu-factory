Act as a platform engineer wiring config & secrets.

Generate file: 04-config-and-secrets.md

Design/review (cite §Config & secrets; compose security-engineering step 03):
- **Config**: non-secret config via **ConfigMap** / env (12-Factor: config in the environment); env parity
  across dev/staging/prod; no environment-specific code branches.
- **Secrets**: NEVER baked into images or committed (flag if found, by file:line + type, no values). Use
  **external secrets** — Vault Agent/CSI driver or External Secrets Operator — mounting at runtime;
  Kubernetes `Secret` is base64 (not encrypted) so enable encryption-at-rest or use the external store.
- **Rotation**: how secrets rotate without redeploy; short-lived creds where possible.
- **Injection**: env var vs mounted file (files are safer — not in `/proc/environ`, easier rotation).
- **Per-environment**: separate secret stores/paths per env; least-privilege access.

For choices: options → pros/cons → tradeoff (simplicity ↔ security) → scored pick, cited.

Output: Metadata header; config strategy (ConfigMap/env); secrets strategy (external store + injection
method + rotation); example manifests (ConfigMap, SecretProviderClass/ExternalSecret); findings if
reviewing (baked/committed secrets = CRITICAL). Inherit the org's secrets mechanism (e.g. Vault) by default.
