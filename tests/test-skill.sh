source "$(dirname "$0")/lib/assert.sh"
K="$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory"; S=$(cat "$K/SKILL.md" 2>/dev/null)
assert_eq "---" "$(head -n1 "$K/SKILL.md" 2>/dev/null)" "frontmatter"
assert_contains "name: ngvu-factory" "$S" "skill name"
for f in "$K"/scripts/*.sh; do b=$(basename "$f"); [ "$b" = lib.sh ] && continue; assert_contains "$b" "$S" "SKILL.md uses $b"; done
for a in "$KF_ROOT"/plugins/ngvu-factory/agents/*.md; do assert_contains "$(basename "$a" .md)" "$S" "SKILL.md spawns $(basename "$a" .md)"; done
for t in "$K"/templates/*.md; do assert_contains "templates/$(basename "$t")" "$S" "SKILL.md uses template $(basename "$t")"; done
for c in "ticket vung-" "epic vung-" "next vung-" "status" "resume vung-" "approve vung-" "rework vung-" "finish-epic vung-" "close vung-" "pr-feedback vung-" "verify vung-" "retro vung-"; do
  assert_contains "/ngvu-factory $c" "$S" "command $c documented"
done
for rule in "Never merge" "intakeApproved" "WAIT FOR ALL" "resumesLeft" "state-check.sh ticket" "jira.md"; do
  assert_contains "$rule" "$S" "SKILL.md states: $rule"
done
assert_contains 'only when line 1 of `FD/decision.md` is `ESCALATE`' "$S" "approve refuses unless decision is ESCALATE"
assert_contains 're-spawn `ngvu-spec-writer`' "$S" "rework re-runs spec when spec is BLOCKED (I3)"
assert_contains 'create only the missing worktrees' "$S" "resume after approved intake recreates missing worktrees (I4)"
assert_contains '`intakeApproved: true` is recorded in `ticket.json`' "$S" "approval survives sessions (I4)"
assert_contains 'exists only locally otherwise, or differs between local and origin: stop' "$S" "epic branch local-only stops (M2)"
assert_contains 'repo-path.sh' "$S" "repo path resolved by repo-path.sh (M6)"
for ref in $(grep -oE '(^|[^/a-z-])scripts/[a-z-]+\.sh' "$K/SKILL.md" | grep -oE 'scripts/[a-z-]+\.sh' | sort -u); do  # skip <other-skill>/scripts/x.sh
  assert_eq yes "$([ -f "$K/$ref" ] && echo yes || echo no)" "referenced $ref exists"
done
out=$(python "$KF_ROOT/tests/lint_text.py" "$K" 2>&1); assert_eq 0 "$?" "skill English-only: $out"
assert_contains "approver trigger 8" "$S" "IT trigger renumbered"
assert_not_contains 'named `ngvu-builder-VUNG' "$S" "no builder name: Agent tool has no name (P-a)"
assert_not_contains 'with the name `ngvu-builder-VUNG' "$S" "no builder name in Build step (P-a)"
assert_contains "builderAgentId" "$S" "builder resumed by recorded agent id (P-a)"
assert_contains "Missing output file" "$S" "missing output file is re-asked once (P-b)"
assert_contains "claim.sh --release" "$S" "declined intake releases the claim (M1)"
assert_contains "started directly" "$S" "direct ticket on an epic child claims and checks blockers (M1)"
assert_contains 'review-guard.sh snapshot' "$S" "review round records worktree HEADs before lenses run"
assert_contains 'review-guard.sh verify' "$S" "review round checks lenses changed no code"
assert_contains 'git -C <worktree> push -u origin <branch>' "$S" "Ready for PR pushes the ticket branch (0.7.0)"
assert_contains 'never retry with force' "$S" "a failed push is never forced"
assert_contains 'Never open, approve or merge the PR' "$S" "the human opens and merges the PR"
assert_not_contains 'Do not push.' "$S" "no leftover human-push instruction"
assert_contains 'ngvu-reviewer-frontend-ui' "$S" "fifth lens for nextjs"
assert_contains 'Open-question gate' "$S" "blocking open questions gate the intake (0.6.0)"
kf_finish
