# Troubleshooting

## Script exit codes

| Exit | Script | Meaning | What to do |
|---|---|---|---|
| 1 | branch-name.sh | Bad input (kind, number or slug) | The factory stops; give a lower-case kebab slug when asked |
| 1 | deploy/bootstrap.sh | First install without `--team` (`-Team`), a team that is not lower-case letters, digits and `-`, an unknown option, or a failed step (marketplace, plugin, rules, settings) | First install: re-run with `-Team <team>` (e.g. `-Team ngvu`); otherwise read the printed step and fix it |
| 1 | deploy/doctor.sh | At least one FAIL line | Fix each FAIL line; WARN lines are advice |
| 2 | verdict.sh, state-check.sh | A factory file is missing or malformed | The run stops; look at the file named in the message |
| 2 | review-guard.sh verify | No snapshot for that round | `/ngvu-factory:ngvu-factory resume vung-<n>`: it takes the snapshot when missing |
| 2 | breakdown.sh | The epic's `08 ## Factory queue` has errors (placeholders, empty R rows, unknown blockers, cycle, uncovered R) | Fix `08-STORY-BREAKDOWN.md` in the epic investigation, then run `epic` again |
| 3 | breakdown.sh | The epic folder has no `## Factory queue` | Not fatal: the epic intake continues with the Jira children only; add the table with `ngvu-epic-investigation` to get the story queue |
| 3 | resolve-task-folder.sh | No investigation folder for the key | Run `ngvu-ticket-investigation` first (`ngvu-epic-investigation` for an epic) |
| 3 | repo-path.sh | Repo not cloned under any `paths.repoRoots` root | Clone it, or fix the roots in `~/.claude/ngvu-factory/machine.json` |
| 3 | cleanup-plan.sh | No such task folder | Check the key and `paths.tasks` |
| 4 | resolve-task-folder.sh | Several folders match | Pick one when the factory asks; consider merging the folders |
| 4 | repo-path.sh | The repo is cloned under two roots | Remove the duplicate clone; the factory never picks one |
| 5 | ref-check.sh, worktree-setup.sh, create-branch.sh | The branch already exists (local or origin) | The factory never reuses branches; rename or delete the old one yourself if it is really obsolete |
| 6 | ref-check.sh | Ref conflict: e.g. a branch `<team>/vung-<e>` blocks `<team>/vung-<e>/EPIC-x` | Rename the blocking branch (`git branch -m`) after checking nobody uses it |
| 7 | worktree-setup.sh, create-branch.sh, blocker-merged.sh | `git fetch` failed | Check VPN and GitHub credentials: `git -C <repo> fetch origin` |
| 8 | worktree-setup.sh, create-branch.sh | Base ref missing | For an epic child: run the epic intake and push the epic branch |
| 9 | worktree-setup.sh | Worktree path already exists | A previous run left it: inspect it, then `git worktree remove <path>` |
| 10 | claim.sh | Child already claimed | Another session has it; `next` tries the following child |
| 11 | blocker-merged.sh | Blocker not merged into the epic branch | Merge the blocker's PR first |
| 11 | merged-to-master.sh | No merge of `VUNG-<n>` on `origin/master` | `verify` runs only after the PR is merged |
| 12 | blocker-merged.sh | Epic branch not on origin | Run `/ngvu-factory:ngvu-factory epic vung-<e>`: it pushes the epic branch |
| 13 | non-ascii-check.sh | Non-English text in added code | Translate the comment; justify intentional string literals in `build.md` |
| 14 | owner.sh --is-own | A touched repo belongs to another team | Informational only: add that team to the PR as reviewers |
| 15 | owner.sh | No `catalog-info.yaml` or no owner line | Treated as unknown owner; check the repo |
| 16 | install.sh, deploy/bootstrap.sh | Files would be overwritten or moved aside | Re-run in a terminal and confirm, or add `--yes` (`-Yes`) after reading the dry run |
| 17 | queue-order.sh | Dependency cycle between epic children | Fix the "Blocks" links in Jira |
| 18 | claim.sh --release | No claim to release for that key | Nothing to do; check the key and the epic folder |
| 19 | review-guard.sh verify | A reviewer committed or left changes in a worktree during review | Read the printed files or commits; keep or drop them yourself (`git -C <worktree> log`, `status`), then `/ngvu-factory:ngvu-factory resume vung-<n>` |
| 20 | unit-test.sh (kind nextjs) | No `node_modules` in the worktree | Run `npm ci` there yourself (needs Artifact Registry auth), then `rework` |
| 21 | error-count.sh | Log window missing, reversed or wider than `verify.maxWindowHours` | Give an exact deploy time; never widen the window without a reason |
| 22 | error-count.sh | No log project configured for that env | Add it to `verify.logProject` in `machine.json` |
| 23 | blocker-merged.sh | Blocker went straight to `master` after the epic branched; the epic branch lacks its code | Choose: a human brings `origin/master` into the epic branch by PR and you re-run the intake, or build the child with `--independent` |
| 24 | cleanup-plan.sh | Nothing to clean in that folder | Nothing to do; a ticket's worktree and branch become candidates once it is merged (or closed) |
| 30 | deploy/bootstrap.sh | A prerequisite is missing: git, a working `python`, or Claude Code >= 2.1.295 | Install it (`claude update`), then run bootstrap again |
| 30 | deploy/ngvu-kit.ps1 | Git Bash not found | Install Git for Windows, or set `CLAUDE_CODE_GIT_BASH_PATH` to its `bash.exe` |

## doctor: "WARN team not set" (or workspace, factoryRepo)

`machine.json` was written before bootstrap knew `-Team`, so the bundled defaults are used (default
team ngvu, default workspace `D:/workspace`, factory repo `D:/workspace/ngvu-ai-factory`) and your branches get
the wrong prefix. Bootstrap keeps an existing `machine.json`, so add the keys by hand in
`~/.claude/ngvu-factory/machine.json`:
`"workspace": "<workspace>"`, `"factoryRepo": "<kit clone>"`, `"team": "<team>"`,
`"branchPrefix": "<team>/"`, `"ownTeams": ["<team>"]`. Run `doctor` again: it prints the values in use.

## Jira MCP not connected

The intake stops before anything else. Connect the Atlassian MCP in Claude Code (`/mcp`) and run
the command again.

## "BLOCKED by ngvu guardrail"

The guardrail hook stopped a push other than `git [-C <repo>] push [-u] origin
<vung-n branch>`, a destructive git command or a Jira write. That is by design: merging, protected
branches and Jira stay with you. Commit and tag messages (`-m`, `--message`,
and a heredoc fed to `git commit|tag|notes`) are treated as text, so a message that mentions a push
is allowed; any `$(...)` inside them is still checked. If it blocks something else that is harmless
(for example `echo "git push"`), rephrase it. Check the hook with
`python <kit clone>/plugins/core-governance/hooks/ngvu_guardrails.py --self-test` (`doctor` runs it too).

## install.sh stops on settings.json

`settings.json is not valid JSON, left untouched`: fix the JSON (or restore
`settings.json.bak-ngvu-factory`) and run the installer again, or install with `--no-guardrails`.

## Python not found

On some Windows machines `python3` opens the Microsoft Store. The scripts try `python`, `python3`
and `py` in that order. If none works, install Python 3 or set `KF_PYTHON` to its path.

## Unit tests fail on a clean master

Run the unit-test script of your machine config (`unitTest.java-service`, by default
`mvn clean install -DskipITs=true -B`) on `master` in the main checkout. If it already fails there,
the build will be BLOCKED for reasons outside the ticket; fix or report the red test first.

## Integration tests (you run them)

The factory never runs ITs. `build.md` lists each related IT with its command under
`## Integration tests (human)`. Start Docker (Rancher Desktop) and the local dependencies, run them,
and write `<tasks>\VUNG-<n>-<slug>\factory\it-results.md` from the template: line 1 `IT: PASS`, `IT: FAIL` or `IT: WAIVED`.
- `IT: FAIL`: `approve` is refused; send it back with `/ngvu-factory:ngvu-factory rework vung-<n> "<what failed>"`.
- The IT really cannot run locally: write `IT: WAIVED` with the reason; the approver still escalates
  it (trigger 8) and `approve` quotes your reason.
`approve` is refused while a ticket is stopped by a BLOCKED spec or build, because nothing has been
reviewed yet.

## Every Bash or PowerShell call is blocked

The core-governance hooks fail closed (`onFailure: block`): if `bash` or `python` cannot start,
each shell call is refused. Run `.\deploy\ngvu-kit.ps1 doctor`; fix the FAIL line (usually
`python` missing or the Microsoft Store stub first on PATH), then start a new session.

## The factory command is not found, or every skill appears twice

With the deploy kit (plugin install) the command is `/ngvu-factory:ngvu-factory`; engineering
skills are `/ngvu-engineering:<skill>`. Seeing both the short `/ngvu-factory` and the plugin one
means an old user-level copy (from `install.sh`) is still in `~/.claude/skills`: run `bootstrap` again (it moves such copies to
`~/.claude/ngvu-legacy-<time>/`) or `doctor` to list them.

## Wrong paths on this machine

Never edit the plugin's `factory.config.json`: an update replaces it. Put only what differs into
`~/.claude/ngvu-factory/machine.json` (for example `paths.tasks`); it is merged over the bundled
config. An invalid JSON there stops every script with a message instead of silently using defaults.

## Spec BLOCKED

The acceptance criteria are missing, contradictory, or depend on an unanswered question. Answer it
(in Jira, `04-IMPLEMENTATION-PLAN.md` or `08-OPEN-QUESTIONS.md`), then
`/ngvu-factory:ngvu-factory rework vung-<n> "<the answer>"`: the spec is rewritten before anything is built.

## Session died after you approved the intake

`/ngvu-factory:ngvu-factory resume vung-<n>` keeps your approval, creates only the worktrees that are missing
and continues at the spec.

## Dashboard shows nothing

Check the server prints the tasks folder you expect, open http://127.0.0.1:8765/ (not `localhost`
on a proxy), and check that some `<tasks>\*\factory\ticket.json` exists. Without `--tasks` the server uses
`paths.tasks` of `~/.claude/ngvu-factory/machine.json`.

## Investigation scripts write to the wrong folder

They use `NGVU_WORKSPACE` (or `NGVU_ROOT`), then `workspace`/`paths.tasks` of `machine.json`,
then the default `D:/workspace`. Unset a stale environment variable, fix `machine.json`, or pass `--root <workspace>`.
