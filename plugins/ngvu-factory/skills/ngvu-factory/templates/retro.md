# Retro: VUNG-<n> <summary>

Date (UTC): <yyyy-mm-dd>    Final stage: <verified | ready-for-pr | needs-human>

## Numbers (cost-report.sh)
Review rounds: <n>    Agent runs: <n>    Tokens: <n or unknown>    pr-feedback rounds: <n>

## Misses
| # | What slipped through | Found by | Should have been caught by | Proposed change |
|---|---|---|---|---|
| 1 | <problem, file:line> | verify / PR reviewer / IT / round 2 | <lens / spec-writer / NGVU-CONTEXT / one-off> | <eval candidate path / pitfall text / AC rule> |

## False alarms
Escalations or CHANGES the human overrode without a code change, and why.

## Worked well
What the factory caught that would otherwise have reached the PR.

## Proposals for the factory repo (each its own commit, after review)
- [ ] eval candidate: <eval folder>/VUNG-<n>-<k>/
- [ ] NGVU-CONTEXT.md: P<n> <pitfall>
- [ ] <agent>.md: <one-line rule>
