---
name: secret-data-guard
description: "Scans and redacts secrets, tokens, PII and real tenant ids with the data-protection-policy tokens, then re-verifies. Use before writing or sharing a report, PR description, ticket explanation, ADR or deck, before quoting logs/diffs/documents, or on \"redact\", \"sanitize\", \"scan for secrets\"."
---

# Secret & Data Guard

The last filter before any content leaves the agent — into a file, a PR, a chat message, or an external
call. Inherits [`~/.claude/rules/GLOBAL-RULES.md`](~/.claude/rules/GLOBAL-RULES.md).

## When to use
- Before writing any deliverable that quotes real content: `<TICKET-KEY>-explanation.md`, an ADR, a PR
  comment, a system-analysis report, or a chat reply.
- Before quoting a **diff**, **log** (including `gcloud logging read` output), **config file**,
  **docker-compose**, or **MongoDB document** (`example_docstore`) in any output.
- Immediately upon noticing a plaintext credential, Vault path, JWT, or API key anywhere in a repo,
  even if it isn't the target of the current task.
- Before any content is sent to an external service (Artifact, web search, third-party API).

## Workflow
1. **Scan the target** — diff, log excerpt, file, report draft, or command output — for the patterns
   below; never skip this because the target "looks like just code" or "just config".
2. **Classify each hit**: secret/credential, token/JWT/session, private key/service-account/Vault
   material, PII/sensitive content, real tenant identifier, or customer identity bound for an
   external service — per
   [`~/.claude/rules/data-protection-policy.md`](~/.claude/rules/data-protection-policy.md).
3. **Redact in place** using the exact tokens: `SECRET_DETECTED_REDACTED`, `TOKEN_REDACTED`,
   `PII_REDACTED`, `TENANT_REDACTED`, `VAULT_REF_REDACTED`, `CUSTOMER_REDACTED`. Never partially mask a value (no
   "sk-...abcd") — replace the whole value with the token.
4. **Verify no secret survives** in the deliverable by re-reading the redacted version specifically
   looking for anything that still resembles a credential, connection string, or real tenant id before
   it is written/sent.
5. **If a secret is found committed or at rest** (repo file, compose file, notes), report only its
   **location and type** (`file:line`, "plaintext DB password") — never its value — and recommend
   rotation + removal. Do not use the credential to complete the task even if it would work; ask the
   user first.
6. **Emit the verdict** and block delivery of anything still marked `BLOCKED` until redacted.

## Output
```
## Scanned Target      — diff / log / file / report / command output, with scope
## Detections          — type + location (file:line or log timestamp); value always redacted
## Redacted Output      — the sanitized content, safe to emit
## Remediation          — rotation/removal steps for anything found at rest
## Verdict              — CLEAN | REDACTED | BLOCKED
```

## Stack notes (ngvu — see the `ngvu-project-stack` skill)
- **Vault**: per-tenant secrets (DB creds, encryption keys) come from Hashicorp Vault via each service's
  `SecretsService` — report the Vault **path**, never the resolved value; use `VAULT_REF_REDACTED`.
- **MP JWT**: `MP_JWT_VERIFY_PUBLIC_KEY_LOCATION` configs and bearer tokens on the wire are `TOKEN_REDACTED`
  material — never echo an `Authorization` header or a JWT string.
- **docker-compose dev/staging** files intentionally hold dev secrets for local `docker-compose up
  --build` — treat them as sensitive anyway; never commit a modified compose file with values still
  filled in, and never paste its secrets into a report.
- **`APP_<NAME>_HOST_PORT` / `.../mp-rest/url` env vars** are config, not secrets, but the values they
  point to (connection strings with embedded credentials) can be — check the value, not just the key
  name.
- **Real tenant ids** (`/{tenant-id}` path segments) from logs or MongoDB documents must become
  `TENANT_REDACTED` in any shared output; use fake ids (e.g. `00000000-0000-0000-0000-000000000000`) in
  examples instead.
- **Sensitive document content** in `example_docstore` documents is `PII_REDACTED` by default. Tenant
  business data may be regulated, so treat it as sensitive even without an obvious "personal" field.
- **gcloud / Cloud Logging** payloads frequently contain full request/response bodies — sanitize fields
  before quoting a log line in any report.
- **Customer identity**: the customer's names, former names and infrastructure ids (for example
  `example-nonprod`, `dev.example.com`, `com.example.*`) become `CUSTOMER_REDACTED` in anything sent to an
  external or public service; internal deliverables (GitHub, Jira, `tasks\`) keep them.

## Anti-patterns to flag
Pasting a raw diff/log/document into a report without scanning it first; partially masking a secret
instead of fully redacting it; assuming a dev/staging value is "not really secret"; using a discovered
credential to unblock the current task instead of reporting and asking for rotation; logging a full
request/response body "for context"; including a real tenant id in an example because it was already in
the source log; treating a Vault **path** as safe to print even though the path itself can reveal
tenant/service topology worth redacting when in doubt.

Related: the `ai-governance-control` skill,
the `prompt-injection-guard` skill,
[~/.claude/rules/data-protection-policy.md](~/.claude/rules/data-protection-policy.md).
