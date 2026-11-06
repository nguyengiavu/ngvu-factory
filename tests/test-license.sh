source "$(dirname "$0")/lib/assert.sh"
L=$(cat "$KF_ROOT/LICENSE" 2>/dev/null); A=$(cat "$KF_ROOT/AUTHORS.md" 2>/dev/null)
N=$(cat "$KF_ROOT/THIRD-PARTY-NOTICES.md" 2>/dev/null); R=$(cat "$KF_ROOT/README.md")
assert_eq "MIT License" "$(head -n1 "$KF_ROOT/LICENSE" 2>/dev/null)" "LICENSE is MIT"
assert_contains "Copyright (c) 2026 Vu Nguyen" "$L" "LICENSE names the copyright holder"
assert_contains "Vu Nguyen" "$A" "AUTHORS names the original author"
assert_contains "software-factory-claude-code" "$N" "third-party notice covers the source factory"
for f in LICENSE AUTHORS.md THIRD-PARTY-NOTICES.md; do assert_contains "]($f)" "$R" "README links $f"; done
# Release gate: the source factory's origin and license must be filled in before publishing.
if [ "${KF_RELEASE:-}" = 1 ]; then
  assert_not_contains "TO CONFIRM" "$N" "THIRD-PARTY-NOTICES.md has no TO CONFIRM left (source URL, license, copyright of software-factory-claude-code)"
else
  echo "  skip: TO CONFIRM check (set KF_RELEASE=1 to enforce)"
fi
kf_finish
