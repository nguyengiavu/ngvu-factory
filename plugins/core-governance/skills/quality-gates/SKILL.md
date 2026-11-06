---
name: quality-gates
description: "Runs the pre-merge/pre-release gate battery (security, tests, performance, database, API contract, observability, rollback, post-deploy check), each PASS/WARN/FAIL/BLOCKED with evidence, then one overall decision. Use before merging, cutting a release, or bumping an image tag."
---

# Quality Gates (pre-merge / pre-release battery)

The gate battery that runs before code ships — it doesn't do the deep analysis itself, it runs each gate,
demands evidence, and aggregates to one decision so nothing merges or releases on vibes. Inherits
[`~/.claude/rules/GLOBAL-RULES.md`](~/.claude/rules/GLOBAL-RULES.md).

## When to use
- Before merging a PR into `master` (or into an epic branch); most ngvu repos have no `develop` (check `git branch -r`).
- Before cutting a release (tag, `release_candidate.sh`/`release.sh`) or promoting to `master`.
- Before a Cloud Build pipeline bumps the image tag in `example_deploy` for a GKE rollout.
- As the last checkpoint of the `ticket-workflow` skill and
  the `feature-build` skill before handoff.

## Workflow
1. **Determine scope.** Identify the diff/branch/service under review, its runtime stack (WildFly+MP vs
   Quarkus — check `pom.xml`), whether it touches persistence (PostgreSQL + JPA by default, MongoDB
   for document workloads — check `persistence.xml`), Pub/Sub consumers, or public API contracts. Declare a budget mode per GLOBAL-RULES §4
   (`STANDARD` for a normal PR, `AUDIT` for a release).
2. **Run each required gate**, citing real evidence (`CONFIRMED`/`STRONG_INFERENCE`/etc. per GLOBAL-RULES
   §1) — never mark PASS without something read or executed:
   - **Security** — delegate to the `security-engineering` skill: no exposed
     secrets/Vault material, no unresolved HIGH/CRITICAL finding, authz (`@PermissionAllowed`/MP JWT) intact.
   - **Tests** — delegate to the `test-strategy` skill: `mvn clean package` (unit) and
     `mvn verify` (integration, deps up via `docker-compose`) both green; coverage of the changed path;
     contract/E2E where applicable.
   - **Performance** — delegate to the `performance-tuning` skill: no regression in
     latency/throughput/CPU/GC on the hot path touched; MP Fault Tolerance (`@Timeout`/`@Retry`/
     `@CircuitBreaker`/`@Fallback`) present on any new/changed remote call.
   - **Database** — delegate to the `sql-optimization` skill or
     the `db-migration` skill: PostgreSQL/JPA + `MigrationRunner` migration safety by default (no
     un-backfilled destructive change, index build sized for the target tenant); Mongo index/query checks
     (no unbounded collection scan) for the Mongo-backed services.
   - **API contract** — delegate to the `api-design` skill: JAX-RS resource compatibility
     (no breaking path/verb/status/DTO change without versioning), Pub/Sub event schema compatibility for
     both producers and existing consumers.
   - **Observability** — delegate to the `observability-sre` skill: logs/metrics/
     tracing present for the new path, correlation id propagated end to end, unexpected exceptions logged
     once at the boundary via the `ExceptionMapper` error model, no leaked stack trace/PII/tenant data.
   - **Release/rollback** — the change ships via PR into `master` (or the epic branch), a concrete rollback
     (previous image tag / migration-down) exists and is stated, not assumed.
   - **Post-deploy verification** — a plan to confirm health after rollout (pod health, error-rate/latency
     dashboards, smoke check) is defined before the gate can PASS, even if not yet executed.
   - If the service repo has its own `ci/ai-quality-gates/*` configs or `cloudbuild.yaml` checks, treat
     those as authoritative for that service and reconcile any conflict in favor of the repo config.
3. **Score each gate** `PASS` / `PASS_WITH_WARNINGS` / `FAIL` / `BLOCKED` (no evidence available →
   `BLOCKED`, not `PASS`).
4. **Aggregate to an overall decision.** Any gate `FAIL` or `BLOCKED` → overall `FAIL`/`BLOCKED`. Any gate
   `PASS_WITH_WARNINGS` with no `FAIL` → overall `PASS_WITH_WARNINGS`. All `PASS` → overall `PASS`.
5. **List blockers with owners.** Each blocker gets a named owner (service owner, security lead, DBA) and
   what evidence would flip it to PASS. If a blocker can only be overridden by accepting risk (e.g. shipping
   with a known-but-scheduled fix), route that override through
   the `ai-governance-control` skill — quality gates report the truth, they
   don't grant exceptions.

## Output
```
## Quality Gate Summary
| Gate | Decision | Evidence | Blockers |
|---|---|---|---|
| Security | | | |
| Tests | | | |
| Performance | | | |
| Database | | | |
| API Contract | | | |
| Observability | | | |
| Release/Rollback | | | |
| Post-deploy Verification | | | |

## Overall Decision            — PASS | PASS_WITH_WARNINGS | FAIL | BLOCKED
## Required Fixes              — ordered list, each with an owner
## Approval Hook                — if an override is requested, route to the ai-governance-control approval handshake
```

## Stack notes (ngvu — see the `ngvu-project-stack` skill)
- **Persistence**: most services are PostgreSQL + JPA/Hibernate with `MigrationRunner` SQL migrations, so
  the database gate defaults to SQL/Hibernate checks (migration safety, locking, N+1); the Mongo-backed services
  get document checks (index/query shape, tenant-partitioned collections). Confirm which applies first.
- **MP Fault Tolerance is mandatory** on MP REST Client / external calls — a changed or new remote call
  without `@Timeout`/`@Retry`(idempotent only)/`@CircuitBreaker`/`@Fallback` is a performance-gate and
  observability-gate FAIL, not a warning.
- **Pub/Sub consumers must be idempotent** with ack-on-success/nack-on-transient-failure and a dead-letter
  path after N attempts — a consumer that can silently drop or double-process a message fails the database/
  observability gates.
- **Error model**: a single `ExceptionMapper<T>` (or Quarkus `@ServerExceptionMapper`) must own the
  exception→HTTP-status mapping; any endpoint that can leak a raw stack trace, container HTML, secrets, or
  another tenant's data fails the security and observability gates outright.
- **Branch + Cloud Build**: the release gate checks the change reached `master` through a reviewed PR;
  the deploy path is a Cloud Build image build/push followed by an `bump_image_tag.sh` bump to
  `example_deploy` — that bump itself needs a CRITICAL-risk approval per
  the `ai-governance-control` skill, independent of this gate battery passing.
- **Multi-tenant**: any gate touching a real `/{tenant-id}` tenant's data or an index build sized for a large
  tenant escalates the database/performance gates to at least HIGH — don't let a clean unit-test run mask a
  tenant-scale risk.

## Anti-patterns to flag
Marking a gate PASS with no evidence read/executed; running gates only on the changed file and skipping
direct callers/callees of a changed contract; treating a `PASS_WITH_WARNINGS` from security as good enough
to merge; skipping the database gate because "it's just Mongo, no migration tool involved"; disabling a
failing test or gate to unblock a merge instead of fixing or escalating it; assuming Hibernate/SQL patterns
apply to a `example_docstore`-backed service; approving a `example_deploy` image bump as part of "the gates
passed" without a separate explicit approval; declaring release-ready with no rollback plan or no
post-deploy verification defined. See also the `ai-governance-control` skill for
the upstream risk classification that determines how strict these gates must be, and
the `ai-output-evaluator` skill for judging whether the evidence cited in this gate
report is itself trustworthy.
