# VUNG-<n>: <summary>

Jira: https://example.atlassian.net/browse/VUNG-<n>
Target branch: <base without origin/>
Source branch: <branch>
Repo: <repo>
Repo owner: <owner> (another team: add them as reviewers for information; they do not gate the merge)

## What changed
- ...

## Acceptance criteria
| AC | Status | Evidence |
|---|---|---|

## Tests
- Unit: <unit-test command for the repo kind> - <result>
- Integration (run by a human, from it-results.md): <IT, result, who/when; or "none affected">

## Risk and rollout
- ...

## Review trail
Factory rounds: <N>. Reviews and decision: <paths.tasks>\<folder>\factory\

## Pull request (opened by a human)
Pushed: git -C <repo path> push -u origin <branch>
Create PR: https://github.com/nguyengiavu/<repo>/compare/<base>...<branch>?expand=1 (<base> = destination without origin/; reviewers come from CODEOWNERS and branch rules)
