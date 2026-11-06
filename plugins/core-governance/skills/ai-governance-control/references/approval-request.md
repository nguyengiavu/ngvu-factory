# Approval request and decision log

The handshake for the **Approval** lane. The list of actions that need approval and the request format
are in [`approval-policy.md`](~/.claude/rules/approval-policy.md); this file adds the stop, the evidence
bar, the decision log and the verify step. **Human-only** actions never enter this handshake: hand them to
a human with the PR link, command or diff.

## Steps
1. **Name the trigger**: which approval-policy item applies, to which service / tenant / environment. An
   action that changes prod, data, security, IAM, secrets or release state without matching an item is
   treated as `HIGH` and still needs approval.
2. **Assemble the request** from observed evidence only:
   - **Action**: the exact command(s) or change, one line.
   - **Risk + why**: the §5 tier and the specific reason.
   - **Blast radius**: services, tenants (the exact `/{tenant-id}`s; cross-tenant impact escalates), data,
     environment.
   - **Dry-run evidence**: what was actually run in a safe mode (`kubectl diff`, a migration against a
     copy, `explain` on a non-prod tenant, `mvn verify` output). When none was possible, say "none
     possible" and why. For a document-store migration (no cross-document transactions), show the
     compensation or backfill path, since rollback is not atomic.
   - **Rollback plan**: concrete: the previous image tag to redeploy, the down-migration, the Vault
     version to restore, the commit to revert.
   - **Approver**: the accountable role or person (service owner, release manager, security lead).
3. **Stop and present** the request in the format below. Nothing executes yet, including the "safe part"
   of the action.
4. **Wait for an explicit go that names this action.** Approval covers one action, one tenant set, one
   environment; anything else is a new request. Silence, a reaction emoji or an earlier approval is not a
   go. If the approver asks for more evidence, return to step 2.
5. **Execute exactly the approved action, verify, report.** Compare the outcome with the dry-run evidence
   (rollout healthy, migration counts match, index built without hurting p95), then close the decision log.

Done when the decision log has every field filled, including `verified-at`.

## Output
```
## Action
## Risk (LOW/MEDIUM/HIGH/CRITICAL) + why
## Blast Radius              — services / tenants / data / environment
## Dry-run Evidence          — what was actually observed, or "none possible" + why
## Rollback Plan
## Approval Needed From      — specific role/person
## Decision Log              — requested-at, decided-by, decision, executed-at, verified-at
```

Before citing dry-run evidence, check it with the `ai-output-evaluator` skill
when it came from the AI's own run.
