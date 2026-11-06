source "$(dirname "$0")/lib/assert.sh"
# Every skill the shipped text sends the reader to ("the `x` skill") must be installed with the kit:
# a skill folder in plugins/*/skills, or a plugin skill `plugin:name` whose plugin kit.json lists in
# upstreamSkills (doctor checks those). A skill turned off in slots.yaml is never a target.
cd "$KF_ROOT" || exit 1
shipped=$(ls -d plugins/*/skills/*/ | xargs -n1 basename | sort -u)
upstream_plugins=$(python -c "import json; print('\n'.join(k.split('@')[0] for k in json.load(open('deploy/kit.json',encoding='utf-8'))['upstreamSkills'] if '@' in k))")
off=$(grep -oE 'off(_when_decided)?: \[[^]]*\]' slots.yaml | sed -E 's/.*\[(.*)\]/\1/' | tr ',' '\n' | tr -d ' ')
refs=$(grep -rhoE 'the `[a-z0-9:-]+` skill' plugins --include=*.md | sed -E 's/the `([^`]+)` skill/\1/' | sort -u)
missing=""; disabled=""
for r in $refs; do
  if [[ "$r" == *:* ]]; then grep -qx "${r%%:*}" <<<"$upstream_plugins" || missing+="$r "
  else grep -qx "$r" <<<"$shipped" || missing+="$r "; fi
  grep -qx "$r" <<<"$off" && disabled+="$r "
done
assert_eq "" "$missing" "every referenced skill is shipped or an upstream plugin skill"
assert_eq "" "$disabled" "no reference to a skill slots.yaml turns off"
# Skills the factory docs name by backticked identifier (not only "the `x` skill") must ship too.
named=$(grep -rhoE '`(ngvu-flow-logs|ngvu-pod-health|playwright-checking)`' plugins presentation guide --include=*.md --include=*.html | tr -d '`' | sort -u)
for n in $named; do assert_eq yes "$(grep -qx "$n" <<<"$shipped" && echo yes || echo no)" "named skill $n ships in plugins/*/skills"; done
for n in ngvu-flow-logs ngvu-pod-health playwright-checking; do
  d="plugins/ngvu-engineering/skills/$n"
  assert_eq "name: $n" "$(sed -n '2p' "$d/SKILL.md" 2>/dev/null)" "$n SKILL.md frontmatter name matches its folder"
  assert_contains "description:" "$(sed -n '3p' "$d/SKILL.md" 2>/dev/null)" "$n SKILL.md has a description"
done
# No doc may claim these skills are missing or optional anymore.
assert_eq "" "$(git grep -nIE '(ngvu-flow-logs|ngvu-pod-health|playwright-checking)[^|]{0,40}(not shipped|optional)' -- . ':!tests/test-skill-refs.sh' ':!docs/CHANGELOG.md' || true)" "no doc says the ops skills are not shipped"
for s in ai-output-evaluator quality-gates; do
  assert_eq yes "$([ -f "plugins/core-governance/skills/$s/SKILL.md" ] && echo yes || echo no)" "$s ships with core-governance"
done
kf_finish
