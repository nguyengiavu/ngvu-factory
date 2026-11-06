# Safe Command Policy

Before proposing or running any shell / `gcloud` / `kubectl` / `mvn` / `git` / `mongo` command,
classify it and apply the gate.

## Auto-safe (read-only) — may run
`git status/diff/log`, `mvn -DskipUTs -DskipITs` build, `mvn test`, `kubectl get/describe/logs`,
`gcloud ... list/describe`, `gcloud logging read` (filtered + time-bounded), Mongo `find`/`explain`
(read), file reads/greps. Prefer these; they generate evidence without side effects.
Non-PROD only: against PROD even these are forbidden outside the deploy process
(`approval-policy.md` § Never).

## ngvu branch → PR flow (standing approval, no per-push prompt)
Work on a ticket/epic branch in a worktree (`<worktrees>\VUNG-<n>\<repo>`, config `paths.worktrees`), commit, then
push it right away with exactly `git -C <worktree> push -u origin <branch>` (branch contains `vung-<n>`).
Then hand the user the GitHub compare link (`.../compare/<base>...<branch>?expand=1`) plus the
`PR-description.md` text; the human opens the PR to `master` (or the epic branch), GitHub
default reviewers are assigned automatically, and teammates review + approve before a human merges.
The AI never merges, never approves a PR, never pushes `master`/`develop`/`release/*`.
`ngvu_guardrails.py` enforces the push shape.

## Personal repos under a personal root (push when the user asks)
Only on a machine whose `~/.claude/ngvu-factory/machine.json` lists `personalRoots` (e.g.
`["D:/Personal"]`; none by default). When the user asks, push any non-protected branch there with
`git [-C <repo>] push [-u] origin <branch>` (no `2>&1` or other redirect: the guardrail miscounts it
as an extra argument), and open a PR with `gh pr create` if asked. Still never force-push, delete
branches, push tags/refspecs, push `master`/`main`/`develop`/`release/*`, or merge/approve a PR.
`ngvu_guardrails.py` allows this only when the session cwd and every `-C`/`cd` target are under
one of those roots.

## Needs review — propose, then run only with a clear go
Local file writes/edits outside the task's repo/worktree (code edits and tests inside it are
MEDIUM — proceed, see `GLOBAL-RULES.md` §5), `mvn verify` that spins
up real deps, `docker-compose up`, Mongo `createIndex` on a **non-prod / small** tenant, config edits.

## Blocked without explicit human approval (see [`approval-policy.md`](approval-policy.md))
Anything with production or destructive blast radius:
`kubectl delete/apply` to prod, `kubectl rollout undo`, `gcloud run/deploy` to prod, image tag bumps in
`example_deploy`, `release*.sh`, `git push` to `develop`/`release/*`/`master` or force-push, tag/delete
branches, `git merge` into `master`/`develop` or merging/approving a GitHub PR, Mongo `dropIndex/drop/deleteMany/updateMany` on prod, `db.createIndex` on a large prod tenant,
Vault writes, IAM changes, `rm -rf`, editing committed `docker-compose` secret files,
`gcloud pubsub topics|subscriptions delete/seek/update/modify-push-config` on prod.

## Rules
1. **Dry-run first** where the tool supports it (`--dry-run`, `kubectl ... --dry-run=server`, migration
   in expand-only mode).
2. **Show the exact command** and its blast radius before running.
3. **Never chain** a blocked command behind a safe one to bypass the gate.
4. **Never** disable safety flags (`--force`, `--no-verify`, `--yes`) to skip a prompt unless the human
   explicitly asked for it in this session.
5. Windows note: this workspace is PowerShell-first; some ngvu ops skills are Bash-only (run via Git
   Bash). Don't silently translate a command in a way that changes its effect.
