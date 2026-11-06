# Data Protection Policy (ngvu: multi-tenant, sensitive)

Treat tenant business data as **sensitive** by default; it may be regulated.

## Never emit (redact with the tokens below)
| Category | Placeholder |
|---|---|
| Password / DB credential / connection string | `SECRET_DETECTED_REDACTED` |
| Access/refresh token, API key, `Authorization`, cookie, session, **JWT** | `TOKEN_REDACTED` |
| Private key / service-account key / Vault material | `SECRET_DETECTED_REDACTED` / `VAULT_REF_REDACTED` |
| PII / personal / medical / document content | `PII_REDACTED` |
| Real customer tenant id | `TENANT_REDACTED` |
| Customer identity in content sent to an external service (see below) | `CUSTOMER_REDACTED` |
| Full raw request/response body (unless sanitized & necessary) | summarize; redact fields |

## Customer identity
- The customer is whoever you set in your own policy (name, former names, and infrastructure ids such as
  `example-nonprod`, `dev.example.com`, `com.example.*`); match all of them.
- Internal deliverables (GitHub PRs, Jira, `tasks\`, team Artifacts) may name the client or tenant.
- Anything sent to an external or public service (web search, context7, a third-party API, a public
  repo/issue, an Artifact shared outside the team) replaces the customer names and those
  infrastructure ids with `CUSTOMER_REDACTED`.

## Tenant isolation
- Every access is keyed by the `/{tenant-id}` path segment. Never read, join, log, or report **across**
  tenants. Per-tenant secrets (DB creds, encryption keys) come from **Vault** — reference the path, never
  the value.
- In examples/tests use obviously-fake tenant ids (e.g. `00000000-0000-0000-0000-000000000000`), never a
  real one copied from logs or notes.

- Never echo `docker-compose` dev/staging secrets. Client-facing error messages stay generic and
  tenant-safe; detail goes to server logs only (the `ngvu-project-stack` skill → *Error & exception handling*).

## Browser sessions & E2E harnesses
- A browser session is a credential: Playwright storage state (`auth.json`, `storageState`), exported
  cookies, HAR files. Keep it in `%LOCALAPPDATA%\ngvu-e2e\VUNG-<n>\` (point `storageState` and the
  login script there), never under the task folders (`<workspace>\tasks\`) or in a repo; delete it and log out when the ticket is done.
- An E2E harness (code, `node_modules`, `test-results/`, traces `*.zip`, videos `*.webm`) lives in
  `<workspace>\.e2e\VUNG-<n>\` (`<workspace>` default `D:\workspace`). The task folder keeps what a reader needs: a README on how to run it,
  screenshots, logs, the HTML report and an evidence index.
- `/ngvu-factory:ngvu-factory cleanup` (no key: `cleanup-plan.sh --all`) lists any session file, `node_modules`
  and trace left under `tasks\`; the human runs the clean-up.

## Logs, reports & deliverables
- `gcloud logging` / Cloud Logging output frequently contains payloads → **sanitize before quoting**.
- Every deliverable that leaves the machine or is shared — `PR-description.md`,
  `<TICKET-KEY>-explanation.md`, a task deck or Artifact, RCA docs, ADRs, PR comments — passes a
  `secret-data-guard` skill scan before it is written/shared.
- Never publish tenant data or secrets to an external service or Artifact.

## When you find a leaked secret in the repo/notes
Report its **location and type only** (`file:line`, "plaintext password"), never the value, and recommend
rotation + removal. Do not "use" a discovered credential even if it would complete the task — ask the user.
