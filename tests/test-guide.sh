source "$(dirname "$0")/lib/assert.sh"
G="$KF_ROOT/guide"
u=$(cat "$G/USER-GUIDE.md" 2>/dev/null); c=$(cat "$G/CHEATSHEET.md" 2>/dev/null); t=$(cat "$G/TROUBLESHOOTING.md" 2>/dev/null)
for h in "## 1. Install" "## 2. Before you start a ticket" "## 3. Run a ticket" "## 4. Run an epic" "## 5. Handle needs-human" "## 6. Open the PR" "## 7. Watch the dashboard" "## 8. Clean up"; do
  assert_contains "$h" "$u" "user guide has $h"
done
for cmd in "ticket vung-" "epic vung-" "next vung-" "status" "resume vung-" "approve vung-" "rework vung-" "finish-epic vung-" "cleanup"; do
  assert_contains "/ngvu-factory:ngvu-factory $cmd" "$c" "cheatsheet lists $cmd"
done
for code in 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17; do
  assert_contains "| $code |" "$t" "troubleshooting explains exit $code"
done
assert_contains "IT: WAIVED" "$t" "troubleshooting records an IT that cannot run as WAIVED, approve still refused on BLOCKED"
assert_contains "guide/USER-GUIDE.md" "$(cat "$KF_ROOT/README.md")" "README links the user guide"
out=$(python "$KF_ROOT/tests/lint_text.py" "$G" 2>&1); assert_eq 0 "$?" "guide clean: $out"
assert_not_contains "catalog owner is not ours" "$(cat "$KF_ROOT/guide/CHEATSHEET.md")" "cheatsheet has no owner trigger"
assert_contains "Bash(git push:*)" "$(cat "$KF_ROOT/guide/USER-GUIDE.md")" "install guide shows a push deny rule (M8)"
assert_contains "same repo" "$(cat "$KF_ROOT/guide/USER-GUIDE.md")" "guide warns about parallel sessions on the same repo (M7)"
assert_contains "claim.sh --release" "$(cat "$KF_ROOT/guide/USER-GUIDE.md")" "guide releases claims with the script (M1)"
kf_finish
