# core-governance

Always-on safety layer. Installed at user scope by the deploy kit (`deploy/ngvu-kit.ps1
bootstrap`, see `deploy/README.md`), which also copies `rules/*.md` to `~/.claude/rules`.

- `hooks/hooks.json` - two PreToolUse hooks; a call is refused when either refuses it.
- `hooks/guard.sh` - Bash, PowerShell, Edit, Write, MultiEdit, NotebookEdit; bash builtins only
  (~0.1 s per call on Windows).
  - `hooks/blocked-commands.tsv` - shell commands refused outright (exit 2): kubectl, helm,
    terraform, gcloud, gsutil, Vault, Mongo, rm -rf, release scripts, destructive git. Third
    column = allow when it also matches (e.g. `--dry-run`).
  - `hooks/protected-paths.tsv` - files for which Edit/Write asks the human first.
- `hooks/ngvu_guardrails.py` - Bash and PowerShell; parses the command (from ngvu-factory 0.7.0).
  Owns `git push`: allows only `git [-C <repo>] push [-u] origin <branch>` where the branch
  contains `vung-<n>` and no master/main/develop/release segment (or any non-protected branch under a
  configured personalRoots folder); blocks refspecs, force, push
  aliases, destructive git and `acli` Jira writes. A quoted string is scanned as a command only
  when an interpreter is on the line, so `grep 'git push'` passes, but a heredoc fed to `python`
  that mentions a push is blocked: write such files with the Write tool.
- `tests/run-guard-tests.sh` - the guardrails self-test plus `tests/guard-cases.tsv` through both
  hooks; add a case for every new rule.

Plugins cannot ship `permissions.deny`, so the Atlassian MCP write tools are denied in
`config/settings.ngvu.example.json` (and added to `~/.claude/settings.json` by `deploy/bootstrap.sh` and `install.sh`).

To change a rule: edit the .tsv (or the CASES of `ngvu_guardrails.py`), add allow/block cases,
run the tests, commit.
