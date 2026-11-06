---
name: context-cost-budget
description: "Declares a FAST/STANDARD/DEEP/AUDIT budget, scope ceiling and stop condition per cost-token-policy, before DEEP/AUDIT work, multi-service scans or Cloud Logging queries."
disable-model-invocation: true
---

# Context Cost Budget

Declares a budget mode before non-trivial work and holds every subsequent context/log expansion to that
mode's ceiling. Inherits [`~/.claude/rules/GLOBAL-RULES.md`](~/.claude/rules/GLOBAL-RULES.md).

## When to use
- At the start of any task beyond a trivial one-file edit — declare the mode before opening a second
  file or running a search.
- Before touching more than one service in the multi-service `<workspace>\services` workspace, or before
  any `gcloud logging read` / Cloud Logging query.
- As the budget check inside the `system-analysis` skill,
  the `incident-response` skill, the `db-migration` skill, and
  the `ticket-workflow` skill — they should apply this skill's procedure (user-invoked)
  instead of re-deriving scope rules inline.
- When scope is creeping mid-task (a "quick look" turning into reading half the workspace) — re-run this
  to re-budget rather than continuing on inertia.

## Workflow
1. **Classify the task** by its actual need, not its apparent size: quick question/tiny review, normal
   daily change, cross-module/cross-service impact analysis, or security/release/incident/migration.
2. **Choose the budget mode** and state it up front:
   - `FAST` — metadata + diff only. Quick question, tiny review.
   - `STANDARD` (default) — diff + directly relevant files + tests. Normal daily engineering.
   - `DEEP` — modules + direct dependencies. Cross-module/cross-service impact analysis.
   - `AUDIT` — full evidence + reports. Security review, release, incident, migration.
3. **Set the scope ceiling before reading anything** — name the one service (never the whole
   workspace), the specific files/modules in bounds, and what is explicitly out of bounds this pass.
4. **Resolve the target service first, once**: read that service's `catalog-info.yaml` and
   the `ngvu-project-stack` skill (and its own `CLAUDE.md`/README if present) to get its
   stack, runtime (WildFly vs Quarkus), and `consumesApis`/`dependsOn` edges — use those edges to decide
   which *other* services are actually in scope instead of guessing or globbing the whole tree.
5. **State the context expansion plan** in the policy order: metadata → diff/changed files → evidence
   map → direct callers/callees → tests/config → logs & cloud resources only if relevant → broader
   modules only if evidence is still insufficient. Summarize large files instead of re-reading them
   whole; prefer one targeted `Grep`/`Glob` over reading a directory.
6. **State the log/query plan** separately if GCP logs are needed: exact time range → resource/service/
   revision filter → structured fields → aggregation (counts/percentiles) → a small sanitized raw sample
   → wider query only if the aggregate proves insufficient. Prefer the ngvu log skills
   (`ngvu-flow-logs`,
   `ngvu-pod-health`) — they already scope by
   service/env — over a raw `gcloud logging read`.
7. **Declare the stop condition** up front: what "enough evidence" looks like for this task, so you know
   when to stop expanding instead of drifting into a full-repo or unbounded-log scan.
8. **Watch for scope creep during execution.** If the ceiling from step 3 turns out to be insufficient,
   don't silently keep pulling in more — restate the budget, justify the escalation (FAST→STANDARD→
   DEEP→AUDIT only), and re-declare a new stop condition.

## Output
```
## Budget Mode            — FAST | STANDARD | DEEP | AUDIT (+ one-line why)
## Scope Ceiling          — the one service/module in bounds; what's explicitly out of bounds
## Context Expansion Plan — ordered steps this task will actually take, per the policy order
## Log/Query Plan         — time range, resource filter, aggregation before raw lines (or "not needed")
## Stop Condition         — what evidence is "enough"; when to stop expanding and re-budget instead
```

## Stack notes (ngvu — see the `ngvu-project-stack` skill)
- `<workspace>\services` is many **independently-versioned** repos with no aggregator build — never
  recurse the whole workspace; resolve the one target service via its `catalog-info.yaml`, then use that
  file's `consumesApis`/`dependsOn` to pull in only the services actually on the request path.
- Cross-service calls are REST + GCP Pub/Sub, not shared Java packages — a "cross-module" `DEEP` task
  here usually means "trace a request across 2-4 services," not "search all repos."
- `gcloud logging read` spends read quota and pulls payloads into context — filter by resource/service/
  revision and stay within the ceiling in `rules/cost-token-policy.md` § GCP log/query cost (≤ 31 days,
  ≤ 5000 entries, aggregate first beyond 24 h, else ask); aggregate (counts, error rates) first.
  `ngvu-flow-logs` already does the interleaved multi-service read for a multi-service request flow
  (web → docs-view → docs → store); `ngvu-pod-health` already scopes pod
  health to one env — use them instead of hand-rolling a broader query.
- Multi-tenant data is keyed by `/{tenant-id}` — scoping a log or data query to the wrong tenant boundary
  is both a cost problem and a data-exposure problem; the scope ceiling must name the tenant, not just
  the service.
- `AUDIT` mode is the default for anything touching prod config, IAM/Vault, a release branch, or a
  migration — align this with the `ai-governance-control` skill's `HIGH`/
  `CRITICAL` classification rather than picking a mode independently.

## Anti-patterns to flag
Skipping the budget declaration because the task "looks small"; defaulting to `DEEP`/`AUDIT` out of
caution without a scope ceiling (that's not safer, just more expensive); recursively scanning the whole
`services` workspace instead of resolving one service via `catalog-info.yaml`; running an unbounded or
unfiltered `gcloud logging read`; pulling raw log lines before trying an aggregation; re-reading a large
file in full when a targeted search or summary would answer the question; letting scope quietly expand
mid-task without restating the mode and stop condition.
