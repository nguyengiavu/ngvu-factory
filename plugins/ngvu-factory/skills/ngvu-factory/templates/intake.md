# Intake: VUNG-<n> <summary>

- Jira: https://example.atlassian.net/browse/VUNG-<n> (<type>, <status>)
- Epic: VUNG-<epic> <epic summary> | none
- Investigation folder: <paths.tasks>\<folder>\ (slug: <slug>)

## Repos and branches
| Repo | Owner (catalog) | Own team? | Base | New branch | Worktree |
|---|---|---|---|---|---|
| <repo> | <owner> | yes/no (if no: send that team the PR for information) | <base-ref> | <branch> | <path> |

Source of the repo list: <file:section of 04-IMPLEMENTATION-PLAN.md>

## Acceptance criteria source
<"Jira field <name>" or "04-IMPLEMENTATION-PLAN.md section <x>"> - <count> criteria found.

## Open questions (08-OPEN-QUESTIONS.md)
| Q-id | Question | Status | Blocking? (why) | Recorded default |
|---|---|---|---|---|
| <Q-id> | <question> | answered / UNANSWERED | yes (🔴 / AC / authz / contract / data / failure) / no | <default or none> |

Blocking and unanswered: <ids, or "none">.
If not none: spec and build wait for answers. To build on the recorded defaults anyway, reply
"build on defaults <ids>"; the approver will still escalate each of them.

## Existing branches with this key (not reused)
- <repo>: <branch>

## Approval
Reply "approve intake" to start spec and build. Nothing is built before that.
