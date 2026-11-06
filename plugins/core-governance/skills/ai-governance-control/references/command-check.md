# Command check

Classify proposed commands one by one, so a mutating step can never ride behind a read-only one. The
tiers come from [`safe-command-policy.md`](~/.claude/rules/safe-command-policy.md); this file is the
procedure for applying them.

## Steps
1. **Split** the input into single commands: break chains on `&&`, `;`, `|`, newlines, and open scripts
   (`release_candidate.sh`, `release.sh`, any `.sh`/`.ps1`) to classify what they run.
2. **Locate** each command: service/repo, environment (local, a non-prod environment, or prod), tenant
   (`/{tenant-id}`) when it touches data, and whether it is local-only or remote (cluster, cloud, database).
3. **Classify** each command against the policy and cite the policy line:
   - `AUTO-SAFE`: the policy's read-only list. A `gcloud logging read` qualifies only when it is filtered
     by resource **and** time-bounded; otherwise narrow it yourself within the ceiling of
     [`cost-token-policy.md`](~/.claude/rules/cost-token-policy.md) § GCP log/query cost (≤ 31 days,
     ≤ 5000 entries); beyond the ceiling it is `NEEDS-REVIEW` — ask first.
   - `PRE-APPROVED`: committing on a `vung-<n>` branch and `git -C <worktree> push -u origin <branch>`
     (`ngvu_guardrails.py` enforces the shape); the personal-root push flow (`personalRoots` in machine.json) when the user asked.
   - `NEEDS-REVIEW`: the policy's "propose, then run only with a clear go" list.
   - `NEEDS-APPROVAL`: the policy's blocked list → [`approval-request.md`](approval-request.md).
   - `HUMAN-ONLY`: merging/approving a PR, merging into `master`/`develop`, pushing
     `master`/`develop`/`release/*`, force-push.
4. **Rate the chain at its worst member.** `mvn test && kubectl apply -f prod.yaml` is `NEEDS-APPROVAL`
   as a whole.
5. **Find the dry-run** for every command above `AUTO-SAFE`: `kubectl ... --dry-run=server` / `kubectl diff`,
   `gcloud ... --dry-run` where it exists, migrations in expand-only mode, `git push --dry-run`. When the
   tool has none, write "no dry-run available".
6. **Keep the safety flags.** Run the command as given, without adding `--force`, `--no-verify` or `--yes`
   unless the human asked for that flag in this session; flag one already present in a pasted command.

Done when every command has a class with a cited policy line and a dry-run (or "none available").

## ngvu gotchas
- `mvn ... -DskipUTs=true -DskipITs=true` is a build with no side effects; check the service `pom.xml`
  defines both flags. `mvn verify` can start Mongo/Vault-backed integration tests, so it is `NEEDS-REVIEW`.
- A "deploy" is the Cloud Build bump of the image tag in `example_deploy` (`bump_image_tag.sh`),
  classed like `kubectl apply` to prod.
- Bash-only ngvu skills (`ngvu-flow-logs`,
  `ngvu-pod-health`) run through Git Bash. Run their
  commands in Bash as written; when a translation to PowerShell would change quoting, globbing or `$()`,
  flag the shell mismatch.

## Output
```
## Commands                    — parsed list, in order, each with service / env / tenant
## Per-command Classification   — AUTO-SAFE | PRE-APPROVED | NEEDS-REVIEW | NEEDS-APPROVAL | HUMAN-ONLY (+ policy line)
## Approval / Human-only        — which commands, whose approval or which human, what evidence to bring
## Dry-run / Safer Alternative  — the dry-run, read-only or expand-only version to run first
## Safe Execution Order         — what may run now vs. what waits
```
