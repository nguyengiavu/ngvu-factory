source "$(dirname "$0")/lib/assert.sh"
D="$KF_ROOT/docs"
need() { # need <file> <heading>...
  local f=$1; shift; local body; body=$(cat "$f" 2>/dev/null)
  assert_eq yes "$([ -s "$f" ] && echo yes || echo no)" "$(basename "$f") exists"
  for h in "$@"; do assert_contains "$h" "$body" "$(basename "$f") has '$h'"; done
}
need "$KF_ROOT/README.md" "## Quickstart" "## What it does" "## Repository layout" "## Documentation"
need "$D/ARCHITECTURE.md" "## Components" "## State contract" "## Exit codes" "## Files per ticket" '```mermaid'
need "$D/WORKFLOW-TICKET.md" "## Steps" "## How the agents trigger" "## Branch and base" "## When it stops" '```mermaid' "builderAgentId" "needs_human --> spec"
need "$D/WORKFLOW-EPIC.md" "## Intake" "## Epic branches" "## Parallel sessions" "## When a blocker counts as done" "## Finishing the epic" '```mermaid'
need "$D/AGENTS-AND-GATES.md" "## Agents" "## Review lenses" "## Test gate" "## Escalation triggers"
need "$D/CHANGELOG.md" "## 0.1.0"
for f in "$KF_ROOT/README.md" "$D"/*.md; do
  for link in $(grep -oE '\]\([^)#:]+\.(md|html|sh|ps1|json)\)' "$f" | sed -E 's/^\]\(//; s/\)$//'); do
    assert_eq yes "$([ -e "$(dirname "$f")/$link" ] && echo yes || echo no)" "$(basename "$f") link $link resolves"
  done
done
out=$(python "$KF_ROOT/tests/lint_text.py" "$D" 2>&1); assert_eq 0 "$?" "docs clean: $out"
# PR links are GitHub compare links, never Bitbucket pull-requests/new URLs.
sk=$(cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/SKILL.md")
assert_contains "/compare/<base>...<branch>?expand=1" "$sk" "SKILL.md builds a GitHub compare link"
assert_contains "/compare/<base>...<branch>?expand=1" "$(cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/templates/PR-description.md")" "PR-description template uses the compare link"
assert_eq "" "$(cd "$KF_ROOT" && git grep -lI 'pull-requests/new' -- . ':!tests/test-docs.sh')" "no Bitbucket pull-requests/new URL is left"
# Frontend repos are nextjs only: no Ivy repo kind, lens, path or wording (state-check tests that kind ivy is rejected).
assert_eq "" "$(cd "$KF_ROOT" && git grep -lIiw 'ivy' -- . ':!tests/test-docs.sh' ':!tests/test-state-check.sh')" "no Ivy reference is left"
kf_finish
