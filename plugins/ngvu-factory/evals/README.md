# ngvu-factory evals

Each case is `prompt.md` (spawns one factory agent in EVAL MODE on an inline, fake diff) plus
`graders/criteria.md` (an LLM judge). Fixtures are invented code; tenant ids never appear.

| Case | Agent | Expected | What it proves |
|---|---|---|---|
| `sec-missing-permission` | security-tenancy | CHANGES | catches missing `@PermissionAllowed`, cross-tenant query, JWT in log |
| `sec-clean-change` | security-tenancy | PASS | no invented findings on a pure rename (false-positive control) |
| `frontend-missing-translation` | frontend-ui | CHANGES | catches a translation key missing in `messages/vi.json` |
| `data-edited-merged-migration` | data-persistence | CHANGES | refuses an edit to a merged Flyway migration |
| `approver-escalates-authz` | approver | ESCALATE | escalates an authorization change although all lenses passed |

Run (costs real agent runs - approve first):

```
bash tools/run-evals.sh ngvu-factory --case sec-clean-change   # one case, one run
bash tools/run-evals.sh ngvu-factory                           # all five
RUNS=3 ABLATION=with-without bash tools/run-evals.sh ngvu-factory   # full comparison
```

Results land in `evals/results/` (git-ignored).

Replacing an agent or skill: run the suite before and after; the replacement must score at least
as well on every case. Add a case for every real miss found in a PR review.

Not covered here: the guard hook has deterministic tests (`core-governance/tests`); slot owners that
live outside this repo (`superpowers:systematic-debugging`, `pr-review`) need their own suites.
EVAL MODE skips worktrees, scripts and NGVU-CONTEXT.md, so these cases test the lens judgement,
not the git/script plumbing.
