source "$(dirname "$0")/lib/assert.sh"
# Epic investigation: breakdown.sh contract (read by /ngvu-factory:ngvu-factory epic), scaffolds, links to the ticket skill.
E="$KF_ROOT/plugins/ngvu-factory/skills/ngvu-epic-investigation"
out=$(bash "$E/scripts/selftest.sh" 2>&1); assert_eq 0 "$?" "epic investigation selftest: $out"
S=$(cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/SKILL.md")
assert_contains '$H/../ngvu-epic-investigation/scripts/breakdown.sh' "$S" "factory epic intake reads the Factory queue"
assert_contains '## Factory queue' "$(cat "$E/templates/08-STORY-BREAKDOWN.md")" "08 template has the Factory queue"
assert_eq yes "$([ -d "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-ticket-investigation/templates/diagrams" ] && echo yes || echo no)" "shared presentation template next to the epic skill"
# F7: the factory spots an unfilled child scaffold by the template's AC placeholder line; keep both in step.
assert_contains 'AC-1  WHEN ...' "$(cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-ticket-investigation/templates/04-IMPLEMENTATION-PLAN.md")" "04 template still has the placeholder the factory checks"
assert_contains 'still holds the template line `AC-1  WHEN ...`' "$S" "factory treats an unfilled 04 as not investigated"
kf_finish
