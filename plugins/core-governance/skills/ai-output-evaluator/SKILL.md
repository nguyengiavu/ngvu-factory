---
name: ai-output-evaluator
description: "Grades the AI's own deliverable (diff, review, RCA, report, ticket explanation) for evidence, hallucination, secrets, requirement coverage, ngvu stack fit, tests and rollback; returns PASS / WARN / FAIL / HOLD with fixes. Use before handing off a deliverable or when asked to self-check an answer."
---

# AI Output Evaluator (self-review before hand-off)

The last check the AI runs on **its own work** before a human sees it — not a rubber stamp, a real critique
against evidence, security, and the ngvu stack. Inherits [`~/.claude/rules/GLOBAL-RULES.md`](~/.claude/rules/GLOBAL-RULES.md).

## When to use
- Before finishing Phase 5/6 of the `ticket-workflow` skill, i.e. right before writing
  `<TICKET-KEY>-explanation.md`.
- After the `feature-build` skill, the debugging skill (`slots.yaml` `bugs.diagnose`), or
  the `refactor` skill produce a diff, and after
  the `system-analysis` skill, the `incident-response` skill, or
  the `bigtech-benchmark` skill produce a report.
- As the last step the `daily-router` skill runs after any work, before handing back to the user.
- When the user directly asks to grade/critique/sanity-check an AI-authored answer.

## Workflow
1. **Restate what is being evaluated**: output type (code diff / PR review / RCA / design / explanation.md /
   analysis report), the service(s) it touches, and the requirement it was supposed to satisfy.
2. **Evidence quality** — for every material claim, check it carries a GLOBAL-RULES §1 evidence class
   (`CONFIRMED`/`STRONG_INFERENCE`/`INFERENCE`/`HYPOTHESIS`/`UNKNOWN`) and a confidence. Reject bare assertions.
3. **Hallucination risk** — spot-check that cited `file:line`, log lines, Mongo indexes/`explain` output, GCP
   resources, and API contracts actually exist as cited (open the file/log yourself if feasible); flag any
   invented method, endpoint, config key, or test result.
4. **Secret/PII exposure** — delegate to the `secret-data-guard` skill; anything it
   would flag is an automatic `BLOCKED` until redacted.
5. **Requirement coverage** — map the output back to the ticket's acceptance criteria (or the user's ask);
   list anything unaddressed or silently descoped.
6. **ngvu stack correctness** — verify the output matches the `ngvu-project-stack` skill:
   JAX-RS + MicroProfile or Quarkus (never Spring/Spring Data idioms), the service's actual store
   (PostgreSQL + JPA by default, MongoDB for document workloads — check `persistence.xml`), MP Fault Tolerance on
   remote calls, a single `ExceptionMapper`-based error model, idempotent Pub/Sub consumers with
   dead-letter handling, and the `master`-trunk branch → PR flow.
7. **Test coverage** — for code changes, confirm unit + integration tests exist per
   the `test-strategy` skill and actually cover the acceptance criteria and failure paths,
   not just the happy path.
8. **Rollback & risk** — for anything that touches prod, data, or a migration, confirm a rollback/rollout plan
   is stated (redeploy previous `example_deploy` image tag, reversible migration, feature flag).
9. **Cost control** — confirm the output didn't scan the full multi-service workspace or pull unbounded GCP
   logs without an `AUDIT`-mode justification (GLOBAL-RULES §4).
10. **Deliverable quality** — when the output is a document someone will *read* (report, RCA, test report,
    `<TICKET-KEY>-explanation.md`, stakeholder one-pager), correctness is not enough; it also has to be
    usable. Run the checklist in
    `references/qa-gate.md` of the `ngvu-evidence-report` skill (ngvu-engineering plugin).
    The four gaps that show up most often, in order:
    - the conclusion is not at the top — the reader must scroll to learn the verdict;
    - there is no section stating **what the work did *not* prove** (a document with no stated limits has
      not been reviewed by its own author);
    - figures are given as totals instead of the distribution that actually answers the question
      ("2 reads on req#1 → 0 on req#2/#3" beats "2 reads across 3 requests");
    - the stated audience is external, but the text is still full of class names and internal env names.
11. **Score each criterion**, roll up to one decision, and list the smallest set of concrete fixes needed to
    move a `FAIL`/`BLOCKED` to `PASS`.

## Output
```
## Evaluation Summary          — what was evaluated, for which requirement/ticket
## Per-Criterion Table         — Criterion | Verdict | Evidence | Issue
                                 (Evidence Quality, Hallucination Risk, Secrets/PII,
                                  Requirement Coverage, Stack Correctness, Test Coverage,
                                  Rollback/Risk, Cost Control)
## Hallucination/Secret Flags  — specific fabricated claims / exposed values (redacted)
## Decision                    — PASS | PASS_WITH_WARNINGS | FAIL | BLOCKED
## Required Fixes              — numbered, specific, smallest set to reach PASS
```

## Stack notes (ngvu — see the `ngvu-project-stack` skill)
- Flag any generated code that reaches for Spring/Spring Data or a shared root
  `pom.xml` — this catalog is JAX-RS + MicroProfile/Quarkus across many independently-versioned repos.
- Flag persistence code that assumes a relational schema when the service actually stores documents via
  `example_docstore`, and any Mongo write path that assumes cross-document transactional atomicity.
- Flag remote calls without `@Timeout`/`@Retry`/`@CircuitBreaker`/`@Fallback`, missing `@PermissionAllowed`
  authz, or Pub/Sub consumers that aren't idempotent / lack a dead-letter path.
- Flag any explanation.md, PR text, or log excerpt that quotes Vault paths, JWTs, or another tenant's
  `/{tenant-id}` data — route to `secret-data-guard` before it ships.
- Flag a release/deploy plan that bumps `example_deploy`, rolls back, or runs `release_candidate.sh`/`release.sh` without human approval.

## Anti-patterns to flag
Grading your own work as PASS by re-reading your own claims instead of the underlying evidence; treating
"no evidence found" as HYPOTHESIS-confirmed instead of UNKNOWN; letting a single missing test slide because
"the logic is simple"; passing an output that redacts a secret in one place but repeats it elsewhere; scoring
stack correctness by vibes instead of checking the `ngvu-project-stack` skill; skipping the rollback check because "it's
just a small change."
