# Cost

## Static prompt cost (measured 2026-10-19)

`claude --plugin-dir plugins/<name> plugin details <name>` (an estimate by Claude Code; it counts the
instruction text only, not the code an agent reads). The table is a snapshot measured 2026-10-19 on
those plugin versions; later versions differ:

| Plugin | Always-on per session | Largest on-invoke items |
|---|---|---|
| core-governance 0.1.0 | ~1,536 tok | safe-command-check ~2.6k, human-approval-workflow ~2.5k, context-cost-budget ~2.3k |
| ngvu-factory 0.2.0 | ~1,556 tok | ngvu-factory ~9.1k, ngvu-ticket-investigation ~4.9k, ngvu-builder ~1.8k |

Each review agent's own instructions cost about 0.9k-1.6k tokens per run; the bulk of a real run
is the diff and files it reads, which only `usage.jsonl` measures.

## Agent runs per ticket (from SKILL.md)

| Path | Agent runs |
|---|---|
| Clean ticket, backend only | spec 1 + build 1 + review 4 + approver 1 = **7** |
| Clean ticket with nextjs | 7 + frontend-ui 1 = **8** |
| Worst case (3 rounds, all lenses) | spec 1 + build 3 + review 15 + approver 1 = **20** |
| Each pr-feedback round | + build 1 + review 4-5 + approver 1 |

## Measuring a real ticket

The orchestrator appends one line per finished agent to `<paths.tasks>/VUNG-<n>-<slug>/factory/usage.jsonl` (tokens / tool uses /
duration as reported by the Agent tool, `null` otherwise). Then:

```
bash <factory home>/scripts/cost-report.sh <paths.tasks>/VUNG-<n>-<slug>/factory
```

or `/ngvu-factory status vung-<n>`. Compare tickets to see which lens or round drives the cost
before changing models (e.g. a lens from opus to sonnet) - and re-run the evals (`tools/run-evals.sh`) after such a
change.
