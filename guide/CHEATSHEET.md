# ngvu-factory cheatsheet

## Commands

Installed with the deploy kit (`bootstrap`), every command starts with
`/ngvu-factory:ngvu-factory`. Only an old user-level install made with `install.sh` uses the
short form `/ngvu-factory <command>`.

| Command | What it does | When | Never does |
|---|---|---|---|
| `/ngvu-factory:ngvu-factory ticket vung-<n>` | Intake, your approval, spec, build, 4 lenses (5 for nextjs), approval, pushes the branch, PR link + description | One ticket with an investigation folder | Open/approve/merge a PR, push master/develop, write Jira |
| `/ngvu-factory:ngvu-factory epic vung-<e>` | Reads children, blockers and the investigation's Factory queue, builds the queue, creates and pushes the epic branches | Once per epic, after `ngvu-epic-investigation` | Open the epic PR |
| `/ngvu-factory:ngvu-factory next vung-<e>` | Claims the next eligible child and runs it as a ticket | In each parallel session | Start a child whose blocker is not merged |
| `/ngvu-factory:ngvu-factory status` | Table of all runs (add `vung-<n>` for one) | Any time | Change anything |
| `/ngvu-factory:ngvu-factory resume vung-<n>` | Continues from `ticket.json` | After a lost session | Redo finished reviews |
| `/ngvu-factory:ngvu-factory approve vung-<n>` | Accepts an ESCALATE decision, writes the PR description | After reading `decision.md` (line 1 `ESCALATE`) | Merge, or approve a BLOCKED spec/build |
| `/ngvu-factory:ngvu-factory rework vung-<n> "<note>"` | Sends the ticket back to the builder with your note | When the result needs changes | Reuse the old resume budget |
| `/ngvu-factory:ngvu-factory close vung-<n> "<reason>"` | Marks the ticket `closed`, prints cleanup commands | Work abandoned or done elsewhere | Delete branches or worktrees |
| `/ngvu-factory:ngvu-factory pr-feedback vung-<n>` | Turns pasted GitHub comments into a new round, pushes new commits | After reviewers commented | Force-push, act on a comment without checking it |
| `/ngvu-factory:ngvu-factory verify vung-<n> [env]` | Read-only post-merge check: merge, CI, health, bounded error counts, smoke list | After the merge reached an environment | Deploy, widen log windows |
| `/ngvu-factory:ngvu-factory retro vung-<n>` | Lists misses and drafts eval candidates | After verify or needs-human | Edit skills or agents |
| `/ngvu-factory:ngvu-factory finish-epic vung-<e>` | Checks all children are merged, the breakdown and the epic DoD, writes `EPIC-PR-description.md`, gives the PR links | End of an epic | Open the epic PR |
| `/ngvu-factory:ngvu-factory cleanup [vung-<n>]` | Writes a clean-up script (worktrees, merged branches, `node_modules`, traces, session files) for you to read and run | After the merge, or to sweep all task folders | Delete anything itself |

Before the factory: `ngvu-ticket-investigation` (folder `<tasks>\VUNG-<n>-<slug>\`) for a ticket,
`ngvu-epic-investigation` (folder `<tasks>\EPIC-VUNG-<e>-<slug>\`) for an epic.

## Branch names

`<team>` is the team given to `bootstrap -Team` (config `branchPrefix` = `<team>/`), e.g. `ngvu`.

| Kind | Pattern |
|---|---|
| Epic | `<team>/vung-<e>/EPIC-<slug>` |
| Epic child | `<team>/vung-<e>/vung-<n>-<slug>` |
| Standalone ticket | `<team>/vung-<n>-<slug>` |

Commits: `VUNG-<n>: <summary>`.

## Where things live

`<workspace>` defaults to `D:\workspace`; `<tasks>` and `<worktrees>` are `paths.tasks` and
`paths.worktrees` in `~/.claude/ngvu-factory/machine.json`.

| What | Where |
|---|---|
| Factory files of a ticket | `<tasks>\VUNG-<n>-<slug>\factory\` |
| Epic queue and claims | `<tasks>\<epic-folder>\factory\` |
| Worktrees | `<worktrees>\VUNG-<n>\<repo>\` |
| Browser sessions / E2E harness | `%LOCALAPPDATA%\ngvu-e2e\VUNG-<n>\` / `<workspace>\.e2e\VUNG-<n>\` |
| Machine config (workspace, team, paths) | `~/.claude/ngvu-factory/machine.json` |
| Installed plugins | marketplace `ngvu-ai-factory` = your `<kit clone>`; rules in `~/.claude/rules` |

## Escalation triggers

1. Flyway migration, Mongo index, backfill or stored-data shape.
2. `@PermissionAllowed`, `@TenantlessAccess`, MP JWT or tenant isolation.
3. A REST/DTO/Pub/Sub contract used by another repo.
4. `cloudbuild*.yaml`, `Dockerfile`, `deployment/`, `standalone.xml`, or a new `pom.xml` dependency.
5. Failure behaviour the AC do not specify.
6. User-facing strings (translation files, every supported locale).
7. An unanswered item in `08-OPEN-QUESTIONS.md` (for an epic child also the epic's `12-OPEN-QUESTIONS.md` rows for its story).
8. A related IT without `IT: PASS` in `it-results.md` (you run ITs and record them).

A repo owned by another team is **not** a trigger: change it on a `<team>/` branch and send that
team the PR for information.
