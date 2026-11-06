# ngvu-ai-factory user guide

From a fresh machine to a merged and verified ticket, for any ngvu team on Windows 11 with
Claude Code. Branches start with your team prefix (`ngvu/` in the examples below).

Placeholders used below:

| Placeholder | Meaning |
|---|---|
| `<kit clone>` | the folder you cloned this repo into (any folder) |
| `<team>` | your team as given to `bootstrap -Team`, e.g. `ngvu`; branches start with `<team>/` |
| `<workspace>` | the folder holding `services\`, `nextjs\`, `tasks\` (default `D:\workspace`) |
| `<tasks>` | `paths.tasks` in your machine config (`<workspace>\tasks`) |
| `<worktrees>` | `paths.worktrees` in your machine config (`<workspace>\.ngvu-worktrees`) |

What you get, as three plugins of the marketplace `ngvu-ai-factory`:

| Plugin | What it gives you | How you call it |
|---|---|---|
| `ngvu-factory` | `/ngvu-factory:ngvu-factory` (ticket, epic, review, PR, verify, retro, cleanup), `ngvu-ticket-investigation`, `ngvu-epic-investigation`, `ngvu-triage`, 8 agents | `/ngvu-factory:ngvu-factory ticket vung-<n>` |
| `ngvu-engineering` | 29 ngvu engineering skills: `pr-review`, `daily-router`, `ticket-workflow`, database, cloud, logs, architecture | `/ngvu-engineering:pr-review`, or just describe the task |
| `core-governance` | guard hooks, governance skills, `ngvu-project-stack`; rules installed to `~/.claude/rules` | always on |

Factory commands are `/ngvu-factory:ngvu-factory <command>`: `ticket`, `epic`, `next`, `status`,
`resume`, `approve`, `rework`, `close`, `pr-feedback`, `verify`, `retro`, `finish-epic`, `cleanup`.
(Only an old user-level install made with `install.sh` uses the short form `/ngvu-factory <command>`.)

## 1. Install

Prerequisites: Git for Windows (Git Bash), Python 3 on PATH as `python` (not the Microsoft Store
stub), Claude Code 2.1.295 or newer, GitHub access, the Atlassian MCP connected (`/mcp`), and an
ngvu workspace. The full table is in `deploy/README.md`.

```powershell
git clone https://github.com/nguyengiavu/ngvu-factory.git <kit clone>
cd <kit clone>
.\deploy\ngvu-kit.ps1 bootstrap -Team <team> -DryRun     # read the plan: plugins, rules, machine config, files moved aside
.\deploy\ngvu-kit.ps1 bootstrap -Team <team>             # add -Workspace <dir> if it is not the default D:/workspace
```

`-Team` is required on the first install (lower-case letters, digits and `-`). Bootstrap adds the
marketplace from your clone, installs the three plugins, copies the rules to `~/.claude/rules`,
writes `~/.claude/ngvu-factory/machine.json` (your workspace, team and paths), adds the Jira-write
denies, moves old user-level copies of the same skills to `~/.claude/ngvu-legacy-<time>/`, and
ends with `doctor`. Open a **new** Claude Code session and run
`/ngvu-factory:ngvu-factory status`; an empty table means it works.

| Task | Command |
|---|---|
| Check this machine | `.\deploy\ngvu-kit.ps1 doctor` (FAIL must be fixed, WARN is advice) |
| Update | `git pull`, then `.\deploy\ngvu-kit.ps1 bootstrap` (plugins load from the clone; rules refresh; machine config kept) |
| Different paths | edit only `~/.claude/ngvu-factory/machine.json`, never the plugin files |
| Remove | `.\deploy\ngvu-kit.ps1 uninstall -DryRun`, then without `-DryRun` |

### What bootstrap does not install

The three plugins carry every ngvu skill and agent the factory and its skills refer to
(`tests/test-skill-refs.sh` keeps it so). Set these up yourself, once per machine:

| Item | Needed for | How |
|---|---|---|
| `superpowers` plugin | debugging, TDD and code-review process skills the slots point to | `/plugin install superpowers@claude-plugins-official` (doctor warns if missing) |
| Jira read access | intake, epic inventory | Atlassian MCP connected (`/mcp`); the epic scripts use the `acli` CLI, logged in |
| Repos | everything | clone them under `<workspace>\services`, `\nextjs` |
| Build tools | the unit-test gate | Maven + JDK for java-service repos; Node + `npm ci` in a nextjs worktree |
| `gcloud`, `kubectl` | `verify` only | logged in to the non-prod projects |
| `gitleaks` (optional) | secret scan of a branch before you push it; required to publish this kit | `winget install Gitleaks.Gitleaks` (macOS `brew install gitleaks`); see *Secret scanning* below |
| Optional skills | not used by the factory | `ngvu-design` (ask the design-system owners), `graphify`, and third-party skills from their upstream (`plugins/ngvu-engineering/README.md`) |

### Portability / your machine

Nothing in the kit depends on where you cloned it or which team you are in:
- Clone the repo to any folder; bootstrap records that folder as `factoryRepo`.
- `-Team <team>` sets `team`, `branchPrefix` (`<team>/`) and `ownTeams` (`[<team>]`).
- `-Workspace <dir>` (default `D:/workspace`) sets `workspace`, `paths.repoRoots`
  (`<workspace>/services`, `/nextjs` with their kinds), `paths.tasks` and `paths.worktrees`.
- All of this goes to `~/.claude/ngvu-factory/machine.json`, merged over the bundled
  `factory.config.json`. Re-running bootstrap keeps the file; edit it by hand to change paths.
- `doctor` prints the workspace, team, factory repo and branch prefix in use and warns when
  `machine.json` lacks one of them. A machine installed before `-Team` existed: add `workspace`,
  `team`, `factoryRepo` (and `branchPrefix`, `ownTeams`) to `machine.json` by hand.
- The investigation scripts find your folders from the environment `NGVU_WORKSPACE` (or
  `NGVU_ROOT`), then `workspace`/`paths.tasks` from `machine.json`, then the default `D:/workspace`; they also
  take `--root <workspace>`. `ngvu-evidence-report` uses `NGVU_WORKSPACE`, then `workspace`.
  The dashboard reads `paths.tasks` from `machine.json` (or takes `--tasks <dir>`).

### Guardrails

Two hooks run before every shell call; a call is refused when either refuses:
- `ngvu_guardrails.py` parses the command. It allows only `git [-C <repo>] push [-u] origin
  <branch>` where the branch contains `vung-<n>` (no refspec, no force, no master/develop/release),
  and blocks every other push, `reset --hard`, `clean -f`, `branch -D`, `checkout .`, push aliases
  and Atlassian CLI (`acli`) writes.
- `guard.sh` blocks deploy and cluster changes (kubectl, helm, terraform, gcloud), Vault, destructive
  Mongo, `rm -rf` and release scripts, and asks before edits to compose, `.env`, credentials,
  `example_deploy` and Claude settings.

Both fail closed: if `bash` or `python` cannot start, the call is blocked (see TROUBLESHOOTING).
The Atlassian MCP write tools are denied in `settings.json`; reading Jira still works.

Why not a plain permission rule: `{ "permissions": { "deny": ["Bash(git push:*)"] } }` matches by
prefix, so it misses `git -C <repo> push ...` and any push run through the PowerShell tool.

### Secret scanning (gitleaks)

The kit has three security layers, and none of them reads the content of your commits:

| Layer | What it checks | When |
|---|---|---|
| Guard hooks (above) | the *command* an agent runs | before every Bash/PowerShell call |
| Rules + `secret-data-guard` skill | what the *agent writes* (reports, PR text, logs it quotes): redaction tokens | while it writes |
| `settings.json` denies | Jira/Confluence write tools | always |

A secret already in a file the builder commits would pass all three. `gitleaks` closes that gap:
it scans files and git history for credentials (keys, tokens, passwords, connection strings) with
fixed rules. It only reads; it never changes code. It is optional on your machine and plays two roles:

- **This kit:** `bash tests/test-gitleaks.sh` scans the working tree and every commit with the
  default rules plus `.gitleaks.toml` (reviewed false positives only). It is skipped without
  gitleaks and required with `KF_RELEASE=1`, the pre-publish gate.
- **A ticket branch** (recommended before you open the PR):
  `gitleaks git --redact --log-opts="origin/master..HEAD" <worktree>`. A hit means stop: remove the
  value, rotate it if it was real, and rewrite the unpushed commit. Never allowlist a real secret.

Install: `winget install Gitleaks.Gitleaks` (Windows), `brew install gitleaks` (macOS), then a new
terminal and `gitleaks version`; `doctor` reports it. A false positive goes into the repo's
`.gitleaks.toml` as a narrow allowlist (one file, one pattern) after someone checked it.

## 2. Before you start a ticket

The factory builds on an investigation; it does not investigate. For `VUNG-<n>`:

1. Run the `ngvu-ticket-investigation` skill so `<tasks>\VUNG-<n>-<slug>\` exists. Starting
   from a log line, Sentry event or tester report instead of a ticket? Use `ngvu-triage` first: it
   turns the signal into a ticket draft (`TRIAGE.md`) for you to file in Jira.
2. Check `04-IMPLEMENTATION-PLAN.md` names the repos that change (e.g. "1 PR in `example_core`").
   The factory takes the repo list from there and stops if it is unclear, or if `04` still holds
   the template line `AC-1  WHEN ...` (a scaffold is not an investigation).
3. Check the acceptance criteria exist: in Jira, or in `04-IMPLEMENTATION-PLAN.md`.
4. Answer what you can in `08-OPEN-QUESTIONS.md`. An unanswered question that could change an AC,
   authorization, a contract, stored data or failure behaviour is **blocking**: the intake will not
   start spec and build until you answer it or explicitly build on its recorded default.
5. If the ticket belongs to an epic, investigate and run the epic intake first (section 4) so the
   epic branch exists.

## 3. Run a ticket

```
/ngvu-factory:ngvu-factory ticket vung-000011
```

The intake reads Jira, finds the folder and repos, and shows: repo and kind (`java-service`,
`nextjs`), owner, base, the new branch `<team>/vung-000010/vung-000011-example-ready`, the worktree
path, where the AC come from, open questions, and branches with the same key that will **not** be
reused. Read it and answer `approve intake` - or correct it. With blocking open questions, answer
them or reply `build on defaults Q12, Q14` (the approver still escalates each). Nothing is built
before you approve.

Then the loop runs and reports one line per step:
```
VUNG-000011: spec written
VUNG-000011: build READY (round 1)
VUNG-000011: round 1 - all four lenses PASS -> approver
VUNG-000011: APPROVE -> pushed -> ready-for-pr
```

- Lenses: security-tenancy, code-conventions, contract-integration, data-persistence; plus
  frontend-ui when a repo is `nextjs`. Reviewers never change code (`review-guard.sh`).
- Unit-test gate by kind: `mvn clean install -DskipITs=true -B` for services (config
  `unitTest.java-service`; a `.bat` path of your own also works), `nx affected -t test typecheck` for Next.js (run `npm ci` in the worktree yourself when asked).
- Integration tests: the builder **lists** them with their commands in `build.md`
  (`## Integration tests (human)`); you run them and record `it-results.md` (section 5).

Everything lands in `<tasks>\VUNG-<n>-<slug>\factory\`: `spec.md`, `build.md`,
`round-<N>\review-*.md`, `decision.md`, `PR-description.md`, `usage.jsonl` (agent runs and tokens;
`/ngvu-factory:ngvu-factory status vung-<n>` ends with the cost report).

## 4. Run an epic

First investigate the epic with the `ngvu-epic-investigation` skill. It writes
`<tasks>\EPIC-VUNG-<e>-<slug>\` (13 files) whose `08-STORY-BREAKDOWN.md` ends with a
machine-read `## Factory queue` table (story, Jira key, repos, blockers), checked by its
`breakdown.sh`, and creates a child folder for every keyed story. Without an investigation folder
the `epic` command stops.

```
/ngvu-factory:ngvu-factory epic vung-000010
```
The epic intake reads the children from Jira and the Factory queue, their blockers, which ones
still need an investigation folder, and the queue order. Test and Sub-task children are never
queued; a story without a Jira key is listed for you to create in Jira. Approve it. The factory
creates `<team>/vung-000010/EPIC-example-epic` in each repo and pushes it.

Now open one Claude Code session per child you want to run in parallel and in each run:
```
/ngvu-factory:ngvu-factory next vung-000010
```
Each session claims a different eligible child and runs section 3 for it. A session with nothing
to do prints why, for example:
```
VUNG-000012: not eligible - blocker VUNG-000011 not merged into origin/<team>/vung-000010/EPIC-example-epic
VUNG-000013: not eligible - needs investigation
```
A blocker counts as done only once its PR is merged into the epic branch; a closed blocker is shown
to you to decide. A blocker merged straight to `master` after the epic branched (exit 23) also
counts, but the child's intake stops and asks you to choose: a human brings `origin/master` into
the epic branch by a reviewed PR and you re-run the intake, or the child is built `--independent`
from `origin/master`.

Parallel sessions on the **same repo** share its `.git` (worktree and branch creation can hit an
`index.lock` - retry the command) and the local Maven repository (two builds installing the same
SNAPSHOT can overwrite each other). Prefer running children of different repos in parallel; for the
same repo, let one unit-test run finish before the other starts.

Cost: a clean ticket runs about seven agents; three review rounds can bring it to 20. Open as many
sessions as your budget allows, not one per child by default.

When every child is merged: `/ngvu-factory:ngvu-factory finish-epic vung-000010` re-checks the
breakdown and the epic DoD, writes `EPIC-PR-description.md` and gives the PR links; you open the
epic PRs to `master`.

## 5. Handle needs-human

A ticket stops at `needs-human` when the spec or build is BLOCKED, review rounds run out, or the
approver escalates. Read the reason the factory quotes, then `decision.md`.

- Related ITs listed in `build.md`: run them, then write `it-results.md` from the template - line 1
  `IT: PASS`, `IT: FAIL` (then `rework`) or `IT: WAIVED` with the reason.
- Accept it: `/ngvu-factory:ngvu-factory approve vung-000012` (you will be asked for your name; it
  is recorded in `decision.md`), then the branch is pushed and you get the PR link. Only when
  `decision.md` says `ESCALATE`; a ticket stopped by a BLOCKED spec or build has nothing reviewed
  to approve.
- Send it back: `/ngvu-factory:ngvu-factory rework vung-000012 "add a backfill step and a rollback note"`
  - the builder gets your note and a fresh budget of two resumes. If the **spec** was BLOCKED, put
  the missing answer in the note: the spec is rewritten first.
- A session died midway: `/ngvu-factory:ngvu-factory resume vung-<n>`.
- The work will not be used (abandoned, or done on another branch):
  `/ngvu-factory:ngvu-factory close vung-<n> "<reason>"`. It prints the cleanup commands; you run them.

## 6. Open the PR

At `ready-for-pr` the factory has pushed the ticket branch and prints, per repo, the GitHub
pull request (compare) link (also in `PR-description.md` and `ticket.json` `prLinks`). Open it;
target: the epic branch for an epic child, `master` for a standalone ticket. Paste
`PR-description.md` as the description. GitHub adds the default reviewers; teammates approve; a
person merges. Move the Jira ticket yourself; the factory never writes to Jira.

| Then | Command | What happens |
|---|---|---|
| Reviewers commented | `/ngvu-factory:ngvu-factory pr-feedback vung-<n>` and paste the comments | A new build and review round answers each comment (FIX / PUSH BACK / QUESTION); new commits are pushed to the same PR |
| Merged and deployed to an env | `/ngvu-factory:ngvu-factory verify vung-<n> dev` | Read-only: merge on master, CI, workload health, error counts in a bounded window, your smoke checklist -> `verify.md`, stage `verified` |
| Learn from it | `/ngvu-factory:ngvu-factory retro vung-<n>` | Lists what the lenses missed and drafts eval candidates; nothing is changed without you |

## 7. Watch the dashboard

```bash
python dashboard/serve.py                          # real runs in <tasks> (paths.tasks of machine.json)
python dashboard/serve.py --tasks <other folder>   # another tasks folder
```
Open http://127.0.0.1:8765/. Epics group their children; each card shows the stage and one chip
per lens (green PASS, red CHANGES, grey pending). Amber cards need you; green cards are ready for
a PR. Click a card to read its files. The server only listens on 127.0.0.1 and is read-only.

## 8. Clean up

The factory never deletes anything; it plans and you run the plan. After the PR is merged (or the
ticket is closed):
```
/ngvu-factory:ngvu-factory cleanup vung-<n>
```
It writes a script into the ticket's `factory\` folder listing merged worktrees, merged local
branches, `node_modules`, Playwright traces and browser session files, and tells you to read it and
run it yourself (`! bash "<file>"`). Every line refuses unsafe work (no `--force`, no `-D`, no
`rm -f`). Without a key it scans every task folder for session files, `node_modules` and traces.
"Nothing to clean" (exit 24) means there is nothing to do. Markdown, `factory/`, screenshots, logs
and reports are never planned for deletion. Delete the remote branch on GitHub (or let the PR
merge do it).

Browser sessions and E2E harnesses never live in `<tasks>`: a session (Playwright storage state,
cookies, HAR) goes to `%LOCALAPPDATA%\ngvu-e2e\VUNG-<n>\`, a harness (code, `node_modules`,
traces, videos) to `<workspace>\.e2e\VUNG-<n>\`. Log out of a session when the ticket is done.

The factory releases a claim itself when you decline an intake. To abandon a child later, release
it so another session can pick it up:
```bash
bash <kit clone>/plugins/ngvu-factory/skills/ngvu-factory/scripts/claim.sh --release <tasks>/<epic-folder>/factory VUNG-<n>
```

## 9. Everyday engineering skills

`ngvu-engineering` skills trigger from what you ask; name one to force it.

| You want | Skill |
|---|---|
| Review a GitHub PR or a diff | `pr-review` |
| "Where do I start" for a daily task | `daily-router` |
| A ticket end to end without the factory loop | `ticket-workflow` |
| Trace a request across example-web, docs, store logs | `ngvu-flow-logs` |
| Pod health on a dev env | `ngvu-pod-health` |
| UI smoke test on dev.example.com | `playwright-checking` |
| Slow query, schema, migration, DB health | `sql-optimization`, `db-schema-design`, `db-migration`, `dba-engineering` |
| Design, ADR, system analysis | `technical-architecture`, `adr`, `system-analysis` |
| Evidence report (HTML) for a finding | `ngvu-evidence-report` |

Third-party skills (`tdd`, `grilling`, `graphify`, `superpowers`, ...) are not shipped; install them
from their upstream if you use them. `doctor` warns when `superpowers` is missing.

### Without superpowers

The factory runs without it: no script calls a superpowers skill. Three skills (`ngvu-triage`,
`ngvu-project-stack`, `ai-output-evaluator`) name `superpowers:systematic-debugging` as the
debugging method and fall back to your own debugging skill, or to plain root-cause work, when it
is missing. Two things to know:

1. Bootstrap turns off the skills `debug`, `diagnosing-bugs` and `code-review` (kit.json
   `skillOverrides`, from `slots.yaml`) so they do not compete with the owners. If one of them is
   your own replacement, keep it on: set it in `~/.claude/settings.json`, e.g.
   `"skillOverrides": { "debug": "on" }`. Bootstrap only adds an override the file does not
   have yet, so your value stays on every re-run.
2. Name your skill when you ask, e.g. "use my `debug` skill to find the root cause"; skills
   trigger from what you ask, so a well-described skill of your own is picked up without any change
   to this repo. A team that wants another owner for everyone changes `slots.yaml` and
   `deploy/kit.json` by PR.

## 10. Change the factory

The factory is code: change it on a branch of this repo, one roadmap item per commit
run `bash tests/selftest.sh`, and open a PR. Teammates pull and re-run
`bootstrap`. Never edit the plugin cache or your installed rules by hand - the next bootstrap
reports or replaces the difference.
