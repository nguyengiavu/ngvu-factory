# ngvu-ai-factory

Versioned home of the ngvu AI development factory, shared by every ngvu team: skills, subagents,
hooks and evals that take a VUNG ticket from a defect signal to a pushed ticket branch with a PR
link, and on to a verified change. It is a Claude Code plugin marketplace with three plugins
(`core-governance`, `ngvu-factory`, `ngvu-engineering`).

The skills and agents assume an example Java/MicroProfile stack, described in
`plugins/core-governance/skills/ngvu-project-stack/SKILL.md` and
`plugins/ngvu-factory/skills/ngvu-factory/NGVU-CONTEXT.md`. The `example_*` service names in them are
placeholders. Edit both files to match your own stack.

## Status

Installed per machine with the deploy kit: clone this repo to any folder and run
`.\deploy\ngvu-kit.ps1 bootstrap -Team <team>` (see [deploy/README.md](deploy/README.md)). The
clone is the marketplace (plugins load from it in place), so `git pull` plus `bootstrap` updates a
machine. This repo is the source of truth; see [docs/CHANGELOG.md](docs/CHANGELOG.md) for the current state.

## What it does

```
signal (log / Sentry / tester) -> ngvu-triage -> ticket draft          (optional)
ticket -> intake (Jira + <tasks>\VUNG-*, open-question gate) -> YOU APPROVE -> worktree on <team>/vung-...
       -> spec-writer -> builder -> [security-tenancy, code-conventions, contract-integration,
                                     data-persistence, frontend-ui (nextjs only)] -> WAIT FOR ALL
                            ^                                                       |
                            +------------ any CHANGES: resume builder (max 2) ------+
                                                                                    v all PASS
          ready-for-pr (branch pushed + PR link + PR-description.md) <- APPROVE - approver
          needs-human (you decide: approve / rework / close)          <- ESCALATE
ready-for-pr -> pr-feedback (GitHub comments -> new round) -> human merges -> verify -> retro
```

The factory pushes only its own `vung-<n>` ticket/epic branches. It never merges, approves or opens
a PR, never pushes `master`/`develop`/`release/*`, never deletes branches or worktrees, never
writes to Jira. Integration tests are run by a human (`it-results.md`).

## Quickstart

```powershell
git clone https://github.com/nguyengiavu/ngvu-factory.git <kit clone>
cd <kit clone>
.\deploy\ngvu-kit.ps1 bootstrap -Team <team> -DryRun     # read the plan
.\deploy\ngvu-kit.ps1 bootstrap -Team <team>             # e.g. -Team ngvu; add -Workspace <dir>
```

`<workspace>` (default `D:\workspace`) is the folder holding `services\`, `nextjs\` and
`tasks\`. Then, in a new Claude Code session: `/ngvu-factory:ngvu-factory status`, then
`/ngvu-factory:ngvu-factory ticket vung-<n>`. Contributors run `bash tests/selftest.sh` first.

## Rules for this repo

- Machines install it with [deploy/README.md](deploy/README.md). A person pushes this repo; the AI does not
  (the guardrail allows only `vung-<n>` ticket branches).
- One change per commit; the commit message says what changed, why, and how it was verified.
- `bash tests/selftest.sh` passes before every commit that touches a script, agent, skill or hook.

## Repository layout

```
plugins/
  ngvu-factory/          ticket lifecycle
    skills/ngvu-factory/            orchestrator, scripts, templates, factory.config.json
    skills/ngvu-triage/             log / Sentry / tester signal -> ticket draft
    skills/ngvu-ticket-investigation/ investigation of one ticket, before intake
    skills/ngvu-epic-investigation/   investigation of an epic and its story queue, before `epic`
    agents/                          spec-writer, builder, 5 review lenses, approver
    evals/                           eval cases for the lenses and the approver
  ngvu-engineering/      29 general ngvu engineering skills
  core-governance/        always-on safety layer
    rules/                           GLOBAL-RULES + policies (bootstrap copies them to ~/.claude/rules)
    skills/                          governance skills + ngvu-project-stack
    hooks/                           guard.sh + ngvu_guardrails.py
    tests/                           guard test cases
deploy/                   per-machine kit: ngvu-kit.ps1, bootstrap / doctor / uninstall, kit.json
config/                   settings example and skill overrides
tests/                    script, agent, skill, install, deploy tests (selftest.sh)
tools/
  install_settings.py     registers the Jira-write denies and skill overrides (bootstrap, install.sh)
  run-evals.sh            runs the evals
  gen-agent-flow-excalidraw.py  agent diagram generator
docs/                     CHANGELOG, cost, architecture and workflows
guide/                    user guide, cheatsheet, troubleshooting
dashboard/                read-only board: python dashboard/serve.py
presentation/             team introduction deck
```

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): components, state contract, exit codes
- [docs/WORKFLOW-TICKET.md](docs/WORKFLOW-TICKET.md): one ticket end to end
- [docs/WORKFLOW-EPIC.md](docs/WORKFLOW-EPIC.md): an epic as parallel child tickets
- [docs/AGENTS-AND-GATES.md](docs/AGENTS-AND-GATES.md): agents, review lenses, test gate, escalation triggers
- [docs/CHANGELOG.md](docs/CHANGELOG.md), [docs/COST.md](docs/COST.md)
- [guide/USER-GUIDE.md](guide/USER-GUIDE.md): install, run a ticket, run an epic, PR flow
- [guide/CHEATSHEET.md](guide/CHEATSHEET.md): commands, branch names, triggers on one page
- [guide/TROUBLESHOOTING.md](guide/TROUBLESHOOTING.md): every exit code and what to do
- [presentation/index.html](presentation/index.html): team introduction with an animated agent diagram

Where any document differs from `plugins/ngvu-factory/skills/ngvu-factory/SKILL.md` and
`docs/CHANGELOG.md`, those two win.

## Tests

```bash
bash tests/selftest.sh          # every tests/test-*.sh plus the guard tests
```

## Install

**Team machines: use [deploy/README.md](deploy/README.md)** (`deploy/ngvu-kit.ps1 bootstrap`): it
installs the three plugins, the rules and the machine config, and moves old user-level copies aside.
The two ways below are its building blocks; use one, never both, or every skill and agent is
offered twice.

**User level** (`install.sh`, without the deploy kit; the command is then `/ngvu-factory <cmd>`
instead of `/ngvu-factory:ngvu-factory <cmd>`):

```bash
bash install.sh --dry-run      # see what would be copied into ~/.claude
bash install.sh                # asks before overwriting changed files; registers the guardrail
                               # hook and the Atlassian MCP write denies (--no-guardrails to skip)
```

**Plugin** (what bootstrap does): remove the user-level `ngvu-factory` skill and `ngvu-*`
agents first.

```
/plugin marketplace add <kit clone>
/plugin install core-governance@ngvu-ai-factory
/plugin install ngvu-factory@ngvu-ai-factory
/plugin install ngvu-engineering@ngvu-ai-factory
```

- `.claude-plugin/marketplace.json`: marketplace `ngvu-ai-factory` with three plugins:
  `core-governance`, `ngvu-factory` and `ngvu-engineering`, each with `.claude-plugin/plugin.json`.
- `slots.yaml`: who owns each role. `config/skill-overrides.ngvu.json`: switches competing skills off.
- `vendor.lock.json`: pinned third-party plugins (superpowers 7.0.0 @ bb92a77).
- `config/settings.ngvu.example.json`: what a repo's `.claude/settings.json` would add,
  including the Jira-write denies a plugin cannot ship.
- Check: `claude plugin validate --strict .` (and each `plugins/<name>`).

Limits: plugins cannot ship always-loaded rules, so `core-governance/rules/` is reference text read
by the governance skills; bootstrap copies it to `~/.claude/rules`, the loaded copy.

## License and authorship

MIT licensed: see [LICENSE](LICENSE). Authors: [AUTHORS.md](AUTHORS.md).
Third-party material: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
