source "$(dirname "$0")/lib/assert.sh"
K="$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory"
for f in NGVU-CONTEXT.md templates/intake.md templates/spec.md templates/build.md templates/review.md \
         templates/decision.md templates/PR-description.md templates/EPIC-PR-description.md templates/queue.md; do
  assert_eq yes "$([ -s "$K/$f" ] && echo yes || echo no)" "$f exists and is not empty"
done
ctx=$(cat "$K/NGVU-CONTEXT.md" 2>/dev/null)
for h in "## Precedence" "## Runtime stacks" "## Build and test" "## Branches and commits" "## Security and tenancy" \
         "## Persistence" "## Contracts and integration" "## Error handling" "## Pitfalls" "## Never do"; do
  assert_contains "$h" "$ctx" "NGVU-CONTEXT has section $h"
done
assert_eq "VERDICT: PASS | CHANGES" "$(head -n1 "$K/templates/review.md" 2>/dev/null)" "review template line 1"
assert_eq "STATUS: READY | BLOCKED" "$(head -n1 "$K/templates/build.md" 2>/dev/null)" "build template line 1"
assert_eq "APPROVE | ESCALATE" "$(head -n1 "$K/templates/decision.md" 2>/dev/null)" "decision template line 1"
out=$(python "$KF_ROOT/tests/lint_text.py" --repo "$KF_ROOT" 2>&1); rc=$?
assert_eq 0 "$rc" "every tracked file is English-only with no real UUIDs: $out"
kf_finish
