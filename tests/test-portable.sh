source "$(dirname "$0")/lib/assert.sh"
# skill text must work in any install location (user level or any plugin).
out=$(python -I "$KF_ROOT/tools/portable-links.py" check "$KF_ROOT" 2>&1); assert_eq 0 "$?" "no relative cross-skill or ~/.claude/skills links in plugin skills: $out"
for p in "$KF_ROOT"/plugins/*/; do
  for s in "$p"skills/*/; do
    assert_eq yes "$([ -f "$s/SKILL.md" ] && echo yes || echo no)" "$(basename "$p")/$(basename "$s") has SKILL.md"
  done
done
assert_eq "" "$(grep -rl --include=*.md -E '\]\((\.\./)+(skills/)?[A-Za-z0-9-]+(/SKILL)?\.md\)' "$KF_ROOT"/plugins/*/rules 2>/dev/null)" "rules link no skill files by relative path"
kf_finish
