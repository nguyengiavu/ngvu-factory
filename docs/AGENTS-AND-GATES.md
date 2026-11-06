# Agents and gates

## Agents

| Agent | Model | Reads | Writes (only) |
|---|---|---|---|
| `ngvu-spec-writer` | opus | `jira.md`, the investigation folder's `README.md` and every numbered `.md`; for an epic child (`<ctx>` names an epic folder) the story's section of the epic `08-STORY-BREAKDOWN.md`, its `09-TEST-PLAN.md` rows and `12-OPEN-QUESTIONS.md` rows (`EQ<n>`); code in the worktrees | `spec.md`; AC copied verbatim, never invented; `STATUS: BLOCKED` when AC are missing or contradictory |
| `ngvu-builder` | opus | spec, previous round reviews, rework notes | commits on the ticket branch + `build.md` (`STATUS: READY` / `STATUS: BLOCKED`) |
| `ngvu-reviewer-security-tenancy` | opus | diff, spec, build | `round-N/review-security-tenancy.md` |
| `ngvu-reviewer-code-conventions` | sonnet | diff, spec, build | `round-N/review-code-conventions.md` |
| `ngvu-reviewer-contract-integration` | sonnet | diff, spec, build, `catalog-info.yaml`, consumers in other repos | `round-N/review-contract-integration.md` |
| `ngvu-reviewer-data-persistence` | sonnet | diff, spec, build | `round-N/review-data-persistence.md` |
| `ngvu-reviewer-frontend-ui` | sonnet | diff, spec, build; only when a repo has kind `nextjs` | `round-N/review-frontend-ui.md` |
| `ngvu-approver` | opus | everything | `decision.md` (`APPROVE` / `ESCALATE`) |

All agents read `NGVU-CONTEXT.md`, then the repo's `CLAUDE.md` if present (it wins). A lens with
nothing to review writes `VERDICT: PASS` and `not applicable: <reason>`.

## Review lenses

P-numbers refer to the pitfalls in `plugins/ngvu-factory/skills/ngvu-factory/NGVU-CONTEXT.md` § Pitfalls.

### security-tenancy
- `@PermissionAllowed` on every new or changed JAX-RS method; admin resources
  (`@TenantlessAccess`, `*_CROSS_TENANT`) only for admin/service callers (P5).
- Tenant id from the path enforced in queries; no cross-tenant reads, caches or logs.
- No secrets, tokens, JWTs, Vault values, PII or document content in code, logs, fixtures or responses.
- Generic client errors through `ExceptionMapper`; no committed compose, env or credential files.

### code-conventions
- Re-runs the unit tests (`unit-test.sh`, config `unitTest.<kind>`) and `non-ascii-check.sh`; a failure is always CHANGES.
- AC implemented with the tests `build.md` claims; JAX-RS + MicroProfile/Quarkus idioms, no Spring.
- MP Fault Tolerance with short timeouts on interactive paths (P7); narrow catches; "no data" vs
  "error" kept apart (P4); reuse existing enums and helpers (P9).
- Commits `VUNG-<n>: ...`, nothing stray committed.

### contract-integration
- Changed REST paths, DTOs, status codes, Pub/Sub topics or messages, with every consumer found in
  `services\` and `nextjs\` listed.
- Backward compatibility, `catalog-info.yaml` dependencies, `APP_<NAME>_HOST_PORT` and `/mp-rest/url`.
- Idempotent Pub/Sub consumers; gates in the service layer, not only in the UI (P6); owners reported.

### data-persistence
- Flyway files append-only, named `V<yyyy.MM.dd>.<seq>__DESCRIPTION.sql`, never editing a merged one.
- JPA entity vs DTO (P3), transactions, locking; Mongo/`example_docstore` query shape and indexes.
- Backward compatibility of stored data; skew margin for cross-database timestamps (P10).

### frontend-ui (only with `nextjs` repos)
- Next.js apps/libs of the Nx workspace; translation keys in every supported locale; client caches;
  accessibility basics; gates not only in the UI (P6).

## Test gate

- Always: `unit-test.sh <worktree> <kind> <base>` in every touched worktree - must be green. It runs
  config `unitTest.<kind>`: `java-service` `mvn clean install -DskipITs=true -B` (default); `nextjs` `nx affected -t test typecheck` (no `node_modules`:
  exit 20, a human runs `npm ci`).
- Integration tests are run by a human: `find-its.sh` lists the `*IT.java` that reference
  changed classes; the builder writes each with the exact command from the repo's
  failsafe/Arquillian config (or `command unknown`) under `## Integration tests (human)`. You run
  them and record `it-results.md` (`IT: PASS | FAIL | WAIVED`). ITs never block the build.
- `non-ascii-check.sh` reports non-English text in added code lines (translation files excluded).
- Never `git add -A`; never commit `docker-compose*`, `*.env`, `credential/`. The builder blocks
  when the spec needs one of them changed; `cloudbuild*.yaml` and `Dockerfile` change only when the
  spec requires it (trigger 4).
- Reviewers never change code: the orchestrator records each worktree's HEAD before a round
  (`review-guard.sh snapshot`) and stops if a HEAD moved or a tree is dirty afterwards (`verify`, exit 19).
- The code-conventions lens re-runs `find-its.sh` and asks for changes when build.md misses an IT;
  it never runs ITs.

## Escalation triggers

APPROVE means "the orchestrator may push the ticket branch; a human opens and merges the PR".
The approver must ESCALATE when the diff:

| # | Trigger | ngvu example |
|---|---|---|
| 1 | Adds/changes a Flyway migration, Mongo index, backfill or stored-data shape | New column in `example_core` `V2026.10.15.1__...sql` |
| 2 | Changes `@PermissionAllowed`, `@TenantlessAccess`, MP JWT config or tenant isolation | Opening an admin endpoint to tenant tokens |
| 3 | Changes a REST/DTO/Pub/Sub contract consumed by another repo | Renaming a DTO field the Next.js app reads |
| 4 | Changes `cloudbuild*.yaml`, `Dockerfile`, `deployment/`, `standalone.xml`, or adds a `pom.xml` dependency | New library in `pom.xml` |
| 5 | Decides failure behaviour the AC do not specify | Choosing fail-open when the payment service times out |
| 6 | Adds or changes user-facing strings | New translation key in every supported locale |
| 7 | Relates to an unanswered item in `08-OPEN-QUESTIONS.md`, or in the epic's `12-OPEN-QUESTIONS.md` for this story (`EQ<n>`); items you accepted to build on defaults (`openQuestionsAccepted`) still count as unanswered | Pricing rule still under discussion |
| 8 | Has a related IT without `IT: PASS` in `it-results.md` (missing, FAIL or WAIVED) | You have not run the listed Arquillian IT yet |

A repo owned by another team is not a trigger. The approver lists such repos under
`## Other-team repos` in decision.md so the PR author sends that team the PR for information.

## Verdict format

Line 1 of every factory file is machine-read by `verdict.sh` (BOM, CRLF and trailing spaces are tolerated):

| File | Line 1 |
|---|---|
| `spec.md` | `# <title>` or `STATUS: BLOCKED` |
| `build.md` | `STATUS: READY` or `STATUS: BLOCKED` |
| `review-*.md` | `VERDICT: PASS` or `VERDICT: CHANGES` |
| `decision.md` | `APPROVE` or `ESCALATE` |
| `it-results.md` | `IT: PASS`, `IT: FAIL` or `IT: WAIVED` |
| `verify.md` | `VERIFY: OK`, `VERIFY: PROBLEM` or `VERIFY: INCOMPLETE` |
