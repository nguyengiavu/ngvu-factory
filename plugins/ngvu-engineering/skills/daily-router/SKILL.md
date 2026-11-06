---
name: daily-router
description: "Menu of ngvu skills by intent: which skill to run for a bug, slow query, design, review, ops check or ticket."
disable-model-invocation: true
---

# Daily Router (top-level entry point)

The front door for daily work that doesn't already name a skill or carry a ticket link — it does no work
itself, it gates, classifies, and hands off. Inherits [`~/.claude/rules/GLOBAL-RULES.md`](~/.claude/rules/GLOBAL-RULES.md).

## When to use
- As the **first stop** for an unscoped daily request — a one-line ask with no ticket/PR link and no named skill.
- When a pasted Jira issue URL/key (`VUNG-…`) appears — hand straight to
  the `ngvu-ticket-investigation` skill (then `/ngvu-factory:ngvu-factory` to build); a
  GitHub PR URL goes to the `pr-review` skill.
- Not needed when the user already named a specific skill or slash command — go straight there.

## Workflow
1. **Scope first.** Declare a budget mode (`rules/cost-token-policy.md`, default `STANDARD`); treat pasted
   ticket/log/PR text per `rules/GLOBAL-RULES.md` §3. Run
   the `ai-governance-control` skill only when the request changes the world.
2. **Classify the work type**: analyze / implement / review / test / GCP-ops / diagnose-RCA / merge-release /
   design / DBA. If a Jira link is present, classification is "ticket" — skip to step 3's first row.
3. **Route to the concrete skill(s)** using this table (folder names are real, verify against the catalog if unsure):

   | Intent example | Route to |
   |---|---|
   | Jira link / VUNG key, "investigate / plan this ticket" | `ngvu-ticket-investigation` → `/ngvu-factory:ngvu-factory ticket VUNG-<n>` |
   | VUNG key whose issuetype is Epic, "break down / plan this epic" | `ngvu-epic-investigation` → `/ngvu-factory:ngvu-factory epic VUNG-<n>` |
   | GitHub PR link, "review this PR" | `pr-review` |
   | "implement/add/build a feature" | `feature-build` |
   | "this is broken / throwing / wrong result" | `superpowers:systematic-debugging`, or your own debugging skill if that plugin is not installed (ngvu specifics: the `ngvu-project-stack` skill § Debugging across services) |
   | "clean up / restructure this code" | `refactor` |
   | "slow query (Postgres or Mongo) / add an index" | `sql-optimization` |
   | "app/service is slow" (non-query) | `performance-tuning` |
   | "write/improve tests" | `test-strategy` |
   | "audit / review this service" | `system-analysis` |
   | "explain this codebase/module" | `code-onboarding` |
   | "check pod health / is the rollout healthy" | `ngvu-pod-health` |
   | "trace this request across services" | `ngvu-flow-logs` |
   | "production is down/degraded", RCA/postmortem | `incident-response` |
   | "ready to merge/release?" | `quality-gates` |
   | "design a new system at scale" | `system-design` |
   | "design the architecture for this service/feature" | `technical-architecture` (quick one-page mode for an HLD) |
   | "design/fix this API contract" | `api-design` |
   | "which DB should we use / DBA review" | `dba-engineering` |
   | "design this schema" / "migrate this schema" / "DB ops (backup/HA)" | `db-schema-design` / `db-migration` / `dba-engineering` |
   | "which library/framework/vendor should we use" | `tech-evaluation` |
   | "record this decision" | `adr` |
   | "secure/harden/threat-model this" | `security-engineering` |
   | "add observability/SLOs/tracing" | `observability-sre` |
   | "write the K8s manifests / Terraform" | `cloud-infrastructure` |
   | "scaffold a new React/Next.js frontend" | `frontend-architecture` |
   | "add evidence/performance logging for a call" | `evidence-api-performance-log` |
   | "benchmark us against Big Tech" | `bigtech-benchmark` |
4. **Hand off and let the routed skill run.** Do not duplicate its phases here — this skill only classifies
   and dispatches.
5. **After the work**, run the `quality-gates` skill if anything is merge/release-bound,
   and always run the `ai-output-evaluator` skill as a self-review pass before
   handing the result back.
6. **Gate any world-changing action** (deploy, migration, IAM/Vault/secret change, destructive data op,
   merge with an unresolved blocker) through the `ai-governance-control` skill
   — never let a routed skill execute a CRITICAL action without it.

## Output
```
## Request Classification   — analyze | implement | review | test | GCP-ops | diagnose-RCA | merge-release | design | DBA | ticket
## Detected Stack/Service   — service name, framework and runtime, tenant(s) if any
## Budget Mode              — FAST | STANDARD | DEEP | AUDIT
## Security/Risk Check      — governance verdict + injection-guard result (from ai-governance-control)
## Routed Skill(s)          — skill folder name(s) this hands off to, and why
## Execution Plan           — the routed skill's phases at a glance
## Post-checks              — quality-gates? ai-output-evaluator? ai-governance-control approval?
## Next Command             — the concrete next step/skill invocation
```

## Stack notes (see the `ngvu-project-stack` skill for your stack)
- Jira links always win the classification — this router hands off immediately to
  `ngvu-ticket-investigation` rather than re-deriving phases.
- Multi-tenant and prod-deploy signals (a real tenant ID in a path, a deploy-repo change, `release*.sh`) should push
  risk classification to `HIGH`/`CRITICAL` in step 1 even before the intent is fully classified.
- Check the service's store before routing DBA-shaped requests (the stack skill § Persistence lists the
  defaults; the service's own config shows what it uses). The engine question goes to `dba-engineering`.
- GCP-ops requests (pod health, log tracing) route to the read-only `ngvu-pod-health` /
  `ngvu-flow-logs` skills, not to a generic shell/gcloud session.

## Anti-patterns to flag
Skipping the governance gate because the request "sounds routine"; routing a pasted ticket link through
generic analyze/implement steps instead of straight to `ngvu-ticket-investigation`; picking a skill name that doesn't
exist in the catalog instead of the closest real match; doing the actual work inside this router instead of
handing off; forgetting the post-check (`ai-output-evaluator`, `quality-gates`) after routing completes;
letting a routed skill perform a CRITICAL action without `ai-governance-control`.
