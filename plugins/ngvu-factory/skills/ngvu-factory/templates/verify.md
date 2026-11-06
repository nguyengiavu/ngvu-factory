VERIFY: OK | PROBLEM | INCOMPLETE

# Verify: VUNG-<n> on <env>

Read-only check after merge. Nothing was deployed, changed or written to Jira by the factory.

## Merge
| Repo | Merged to master | Evidence (merged-to-master.sh) |
|---|---|---|

## CI
<gcloud builds list result for the merge sha, or "not configured - checked by <name> in the console: <result>">

## Rollout health (pod health, ENV=<env>)
| Workload | Ready | Restarts | Image / revision as reported | Note |
|---|---|---|---|---|

## Errors (error-count.sh, deploy time T = <UTC, given by the human>)
| Container | [T-1h, T) | [T, T+1h) | Verdict |
|---|---|---|---|

## Smoke (from 05-TEST-PLAN.md - ticked by the human)
- [ ] <scenario>

## Result
OK only if every repo is merged, CI is green or confirmed, workloads are ready without new restarts,
errors did not rise, and every smoke item is ticked. Otherwise PROBLEM (something is wrong) or
INCOMPLETE (something was not checked) - say what.

## Jira comment (paste by hand)
<two or three lines: merged, verified on <env> at <time>, result>
