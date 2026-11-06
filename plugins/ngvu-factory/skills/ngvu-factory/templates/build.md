STATUS: READY | BLOCKED

# Build: VUNG-<n> <spec title>

## Summary
What the branch does now. Files changed per repo.

## Acceptance criteria
1. [x] <AC id>: <evidence - command and result, test name>

## Validation
| Repo | Command | Result |
|---|---|---|
| <repo> | unit-test.sh <kind> | BUILD SUCCESS, Tests run: <n>, Failures: 0 |
| <repo> | non-ascii-check.sh | none |

## Integration tests (human)
ITs printed by find-its.sh; a human runs them and fills it-results.md. "none" when it printed nothing.
| Repo | IT class | Command |
|---|---|---|
| <repo> | <FooIT> | <exact command from pom.xml, or "command unknown: <why>"> |

## PR feedback
Only after /ngvu-factory pr-feedback. One row per item in pr-feedback-<k>.md.
| # | Reviewer comment (short) | Answer | Evidence |
|---|---|---|---|
| 1 | <comment> | FIX / PUSH BACK / QUESTION | <sha, or reason with file:line, or the question> |

## Commits
- <sha> VUNG-<n>: <message>

## Blocked
Only when STATUS: BLOCKED - what blocks, exactly, and what decision is needed.

## Log
### Round <N>
What was done; for rounds after the first, each review finding and what was done about it.
