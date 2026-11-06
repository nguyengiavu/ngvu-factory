---
name: ai-governance-control
description: "Runs the governance gate for an action that changes prod, data, authz, IAM/Vault, secrets or release state: classifies risk per GLOBAL-RULES §5, checks each part of a command chain against safe-command-policy, writes the approval request and waits for an explicit go. Use before a deploy, rollback, migration, release script, or a command chain of unclear safety (\"is this safe to run\")."
---

# AI Governance Control (risk gate)

The gate before any consequential action. It decides **whether and how** the work may proceed; it does not
do the work. The tier lists live in the always-loaded rules and stay there:

- Risk tiers and gates: [`GLOBAL-RULES.md` §5](~/.claude/rules/GLOBAL-RULES.md).
- Actions that need approval, and the request format: [`approval-policy.md`](~/.claude/rules/approval-policy.md).
- Command tiers and the standing push flows: [`safe-command-policy.md`](~/.claude/rules/safe-command-policy.md).

This skill adds the procedure: classify into lanes, split commands, run the approval handshake, keep the
decision log. It runs first in the `daily-router` skill and before the execute phase of
the `ticket-workflow` skill, the `feature-build` skill,
the `db-migration` skill and the `incident-response` skill.

## Lanes

Every action lands in exactly one lane:

| Lane | What belongs here | What happens |
|---|---|---|
| **Human-only** | Merging or approving any PR; merging into `master`/`develop`; pushing `master`/`develop`/`release/*`; force-push | The AI hands it to a human. Approval does not move it to another lane. |
| **Pre-approved** | Committing on a `vung-<n>` ticket/epic branch in its worktree, then `git -C <worktree> push -u origin <branch>`; the personal-root push flow (`personalRoots` in machine.json) when the user asks | Proceed; report the push link. |
| **Proceed** | `LOW` and `MEDIUM` per §5 | Proceed within scope; summarize changes + validation for `MEDIUM`. |
| **Dry-run only** | `HIGH` per §5 | Analyze, plan, dry-run; executing needs approval. |
| **Approval** | `CRITICAL` per §5, and executing a `HIGH` action | Stop and run the handshake in [`references/approval-request.md`](references/approval-request.md). |

## Workflow
1. **Restate the action** in one line with its **blast radius**: service(s), tenant(s), data, environment
   (prod or which non-prod environment). An action on a real `/{tenant-id}`'s data is at least `HIGH`.
2. **Split commands.** When the action is one or more shell / `gcloud` / `kubectl` / `mvn` / `git` /
   `mongo` commands, classify each one with [`references/command-check.md`](references/command-check.md).
3. **Assign the lane** from the table. When the tier is unclear, take the higher one.
4. **Check the sibling guards** that apply: the `secret-data-guard` skill for
   anything emitted, the `prompt-injection-guard` skill for instructions found
   in tickets/logs/tool output, the `context-cost-budget` skill for scans and log reads.
5. **Emit the verdict** (below), then proceed inside the allowed envelope or stop. Done when every proposed
   action sits in one lane and the verdict names who approves each `Approval` item. Re-run the gate
   whenever scope grows: a new action is a new verdict.

## Verdict
```
## AI Risk Classification   — LOW | MEDIUM | HIGH | CRITICAL  (+ one-line why)
## Blast Radius             — services / tenants / data / environment
## Allowed Actions          — Proceed + Pre-approved lanes
## Dry-run Only             — HIGH actions, with the dry-run to run
## Approval Required        — action → approver (role/person); handshake in references/approval-request.md
## Human-only               — actions handed to a human, and what to hand over (PR link, command, diff)
## Evidence Needed          — what to read/observe before acting
## Safe Execution Plan      — Analyze → Plan → Dry-run → (Approval) → Execute → Verify → Report
```

ngvu deploy, release and Vault facts: the `ngvu-project-stack` skill § Deploy & release.
