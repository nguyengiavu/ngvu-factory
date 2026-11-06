source "$(dirname "$0")/lib/assert.sh"
A="$KF_ROOT/plugins/ngvu-factory/agents"
check() { # check <agent> <model> <output-file-fragment>
  local f="$A/$1.md" body
  body=$(cat "$f" 2>/dev/null)
  assert_eq "---" "$(head -n1 "$f" 2>/dev/null)" "$1 has frontmatter"
  assert_contains "name: $1" "$body" "$1 name matches file"
  assert_contains "model: $2" "$body" "$1 model $2"
  assert_contains "description: " "$body" "$1 has description"
  assert_contains "tools: " "$body" "$1 has tools"
  assert_contains "NGVU-CONTEXT.md" "$body" "$1 reads NGVU-CONTEXT.md"
  assert_contains "$3" "$body" "$1 names its output file"
  assert_contains "Never push" "$body" "$1 forbids push"
  assert_contains "never return it inline" "$body" "$1 must write its file, not return it inline (P-b)"
}
check ngvu-spec-writer opus "spec.md"
check ngvu-builder opus "build.md"
check ngvu-approver opus "decision.md"
for l in security-tenancy:opus code-conventions:sonnet contract-integration:sonnet data-persistence:sonnet frontend-ui:sonnet; do
  check "ngvu-reviewer-${l%%:*}" "${l##*:}" "review-${l%%:*}.md"
  assert_contains "VERDICT: PASS" "$(cat "$A/ngvu-reviewer-${l%%:*}.md" 2>/dev/null)" "${l%%:*} uses verdict line"
done
assert_contains "unit-test.sh" "$(cat "$A/ngvu-builder.md" 2>/dev/null)" "builder runs unit tests via config (M5)"
assert_contains "unit-test.sh" "$(cat "$A/ngvu-reviewer-code-conventions.md" 2>/dev/null)" "code lens runs unit tests via config (M5)"
for a in "$A"/*.md; do
  assert_not_contains 'mvn-unit.bat"' "$(cat "$a")" "$(basename "$a") does not hard-code the unit script (M5)"
  assert_not_contains 'following `templates/' "$(cat "$a")" "$(basename "$a") uses absolute template paths (M5)"
done
assert_contains "find-its.sh" "$(cat "$A/ngvu-builder.md" 2>/dev/null)" "builder discovers ITs"
assert_contains "non-ascii-check.sh" "$(cat "$A/ngvu-builder.md" 2>/dev/null)" "builder checks comments"
AP=$(cat "$A/ngvu-approver.md" 2>/dev/null)
assert_not_contains "--is-own" "$AP" "approver does not escalate on repo owner"
assert_contains '8. has a related IT without a human `IT: PASS` in `it-results.md`' "$AP" "approver has 8 triggers; ITs are run by a human"
assert_contains "## Other-team repos" "$AP" "approver lists other-team repos for information"
assert_contains "## Other-team repos" "$(cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/templates/decision.md" 2>/dev/null)" "decision template has other-team section"
assert_contains "find-its.sh" "$(cat "$A/ngvu-reviewer-code-conventions.md" 2>/dev/null)" "code lens re-runs IT discovery"
assert_contains '## Integration tests (human)' "$(cat "$A/ngvu-reviewer-code-conventions.md")" "code lens compares ITs with the human list; waivers live in it-results.md"
assert_contains 'Do not run ITs' "$(cat "$A/ngvu-reviewer-code-conventions.md")" "code lens never runs ITs"
B=$(cat "$A/ngvu-builder.md")
assert_contains 'Never touch `docker-compose*`, `*.env`, `credential/` or merged Flyway migrations.' "$B" "builder never touches compose/env/credentials, as NGVU-CONTEXT says"
assert_not_contains 'credential/`, merged Flyway migrations, `cloudbuild*.yaml`' "$B" "no spec exception for compose/env/credentials"
out=$(python "$KF_ROOT/tests/lint_text.py" "$A" 2>&1); assert_eq 0 "$?" "agents English-only: $out"
assert_contains "owner.sh <worktree>" "$(cat "$A/ngvu-reviewer-contract-integration.md")" "contract lens runs owner.sh on the worktree (P-c)"
assert_contains "owner.sh <worktree>" "$(cat "$A/ngvu-approver.md")" "approver runs owner.sh on the worktree (P-c)"
kf_finish
