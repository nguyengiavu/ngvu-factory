# Deploy the ngvu factory to a machine

One clone of this repo per machine is the kit: it is the plugin marketplace (loaded in place), the
source of the rules, and the place `bootstrap` runs from. Any ngvu team, Windows 11. Below,
`<kit clone>` is the folder you cloned into, `<team>` your team (e.g. `ngvu`) and
`<workspace>` the folder holding your repos and task folders (default `D:\workspace`).

## Prerequisites

| Need | Why | Check |
|---|---|---|
| Git for Windows (Git Bash) | scripts, hooks (`bash`) | `git --version` |
| Python 3 on PATH as `python` (not the Microsoft Store stub) | guardrail hook, factory scripts; the hooks fail **closed** without it | `python -c "import sys"` |
| Claude Code >= 2.1.295 | `onFailure: block` on the guard hooks | `claude --version` |
| GitHub access to `github.com/nguyengiavu` (SSH key in ssh-agent, or a stored HTTPS credential) | clone and update | `git ls-remote <repo url>` |
| Atlassian MCP connected in Claude Code | the factory reads Jira (writes are denied) | `/mcp` |
| ngvu workspace with `services\`, `nextjs\`, `tasks\`; Maven on PATH | repo roots, unit-test gate | doctor |
| Optional: gcloud + kubectl (dev contexts), Node | `verify`, log and GKE skills, `ngvu-evidence-report` | doctor warns only |
| Optional: gitleaks (`winget install Gitleaks.Gitleaks`) | secret scan of a ticket branch; required to publish this kit (`KF_RELEASE=1`) | doctor warns only |

## Install

```powershell
git clone https://github.com/nguyengiavu/ngvu-factory.git <kit clone>
cd <kit clone>
.\deploy\ngvu-kit.ps1 bootstrap -Team <team> -DryRun                     # read the plan
.\deploy\ngvu-kit.ps1 bootstrap -Team <team> [-Workspace <workspace>]    # do it (asks before moving files)
```

From Git Bash: `bash deploy/bootstrap.sh --team <team> [--workspace <dir>] [--dry-run] [--yes]`.
`-Team` (`--team`) is required on the first install, also for the dry run; it must be lower-case
letters, digits and `-`. `-Workspace` defaults to `D:/workspace` (`kit.json` `defaultWorkspace`).

What it does, in order (`deploy/bootstrap.sh` header has the details):
1. checks the prerequisites;
2. adds the marketplace `ngvu-ai-factory` from this clone (`--source <git url>` for a cached,
   versioned copy instead);
3. installs `core-governance`, `ngvu-factory`, `ngvu-engineering` at user scope;
4. copies `plugins/core-governance/rules/*.md` to `~/.claude/rules/` (plugins cannot ship
   always-loaded rules); a changed file is backed up to `~/.claude/rules.bak-<time>/`;
5. writes `~/.claude/ngvu-factory/machine.json` from `-Team` and `-Workspace` (kept if it exists;
   it overrides the bundled `factory.config.json` and survives updates);
6. adds the Atlassian MCP write denies and the kit `skillOverrides` to `~/.claude/settings.json`
   (only missing entries; backup `settings.json.bak-ngvu-factory`); removes a user-level
   `ngvu_guardrails.py` hook left by install.sh;
7. moves user-level copies of skills/agents the plugins now ship (an older manual install) to
   `~/.claude/ngvu-legacy-<time>/`, so nothing is offered twice; `-KeepLegacy` skips this;
8. runs `doctor`.

Open a new Claude Code session afterwards. Commands are namespaced by plugin:
`/ngvu-factory:ngvu-factory ticket vung-<n>`, `/ngvu-engineering:pr-review`, ...

## Portability / your machine

The kit has no fixed path or team; everything machine-specific is in one file,
`~/.claude/ngvu-factory/machine.json`, written on the first bootstrap (a full example is
`config/machine.example.json`; the file itself never goes into this repo):

| Key | Value written | From |
|---|---|---|
| `workspace` | `<workspace>` | `-Workspace` (default `D:/workspace`) |
| `factoryRepo` | `<kit clone>` | the folder bootstrap runs from |
| `team`, `branchPrefix`, `ownTeams` | `<team>`, `<team>/`, `[<team>]` | `-Team` |
| `paths.repoRoots` | `<workspace>/services` (java-service), `/nextjs` (nextjs) | `-Workspace` |
| `paths.tasks`, `paths.worktrees` | `<workspace>/tasks`, `<workspace>/.ngvu-worktrees` | `-Workspace` |
| `unitTest.<kind>` (optional) | not written; default java-service `mvn clean install -DskipITs=true -B` | add by hand to use your own command or `.bat` |
| `reportLanguage` (optional) | not written; default `en` | add by hand, e.g. `"vi"`: investigation reports are written in that language (headings stay English) |
| `personalRoots` (optional) | none | add by hand, e.g. `["D:/Personal"]`: the guard lets you push any non-protected branch from your own repos there |
| `serviceCatalog` (optional) | none | add by hand: path of a Markdown service catalog the agents may read |

- Re-running bootstrap keeps the file; to move a folder, edit the file by hand (only the keys that
  differ are needed; the rest comes from the bundled `factory.config.json`).
- `doctor` prints the workspace, team, factory repo and branch prefix in use, checks every path,
  and warns when `machine.json` lacks `workspace`, `team` or `factoryRepo`. A machine installed
  before `-Team` existed: add those keys (and `branchPrefix`, `ownTeams`) by hand.
- Skills and agents refer to `<workspace>` and `<tasks>` resolved from this config; the scripts
  read it directly (investigation scripts: `NGVU_WORKSPACE`/`NGVU_ROOT`, then `machine.json`,
  then the default `D:/workspace`; `--root <workspace>` overrides).

## Check, update, remove

```powershell
.\deploy\ngvu-kit.ps1 doctor        # read-only; FAIL lines must be fixed, WARN lines are advice
git pull; .\deploy\ngvu-kit.ps1 bootstrap   # update: plugins reload from the clone, rules are refreshed
.\deploy\ngvu-kit.ps1 uninstall -DryRun     # then without -DryRun
```

Uninstall removes the plugins and the marketplace only; rules, machine config, settings entries and
backups stay (it prints where). To go back to an old manual install, move
`~/.claude/ngvu-legacy-<time>/*` back into `~/.claude/`.

## Notes

- Third-party skills are not shipped (see `plugins/ngvu-engineering/README.md`); doctor reports
  `superpowers` if it is missing.
- Never edit files in the plugin cache or in this clone to change your machine's paths: use
  `machine.json`. Changes to the factory itself go through a branch and a PR on this repo.
