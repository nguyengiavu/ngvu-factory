source "$(dirname "$0")/lib/assert.sh"
# cleanup-plan.sh: read-only plan; the written script only holds commands that refuse unsafe work.
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T/fx"; CP="$KF_S/cleanup-plan.sh"
R="$T/services/example_x"; git clone -q "$T/fx/origin.git" "$R" 2>/dev/null; git -C "$R" config core.autocrlf false
B=ngvu/vung-21-a; WT="$T/wt/VUNG-21/example_x"
git -C "$R" worktree add -q -b "$B" "$WT" origin/master 2>/dev/null
git -C "$WT" commit -q --allow-empty -m "VUNG-21: a" && git -C "$WT" push -q origin "$B" 2>/dev/null
git -C "$R" checkout -q master && git -C "$R" merge -q --no-ff "$B" -m "Merged in $B (pull request #1)" && git -C "$R" push -q origin master 2>/dev/null

F="$T/tasks/VUNG-21-a"; mkdir -p "$F/factory" "$F/e2e/node_modules/pkg" "$F/e2e/test-results" "$F/e2e/evidence"
ticket() { printf '{"key":"VUNG-21","epic":null,"stage":"%s","repos":[{"repo":"example_x","kind":"java-service","owner":"ngvu","worktree":"%s","branch":"%s","base":"origin/master"}]}' "$1" "$WT" "$B" > "$F/factory/ticket.json"; }
echo '{"cookies":[{"name":"s","value":"x"}],"origins":[]}' > "$F/e2e/auth.json"
echo zip > "$F/e2e/test-results/trace.zip"; echo png > "$F/e2e/evidence/K01.png"

ticket verified
out=$(bash "$CP" "$F" --write "$T/clean.sh" 2>&1); rc=$?
assert_eq 0 "$rc" "plan with items exits 0: $out"
for k in WORKTREE BRANCH SECURITY DEPS TRACE; do assert_contains "$k" "$out" "plan lists $k"; done
assert_not_contains "K01.png" "$out" "screenshots are evidence and stay"
S=$(cat "$T/clean.sh")
assert_contains "worktree remove '$WT'" "$S" "written script removes the worktree"
assert_contains "branch -d '$B'" "$S" "written script deletes the merged branch with -d"
C=$(grep -v '^#' "$T/clean.sh")
for bad in "--force" "branch -D" "rm -rf" "rm -f" "push"; do assert_not_contains "$bad" "$C" "written script never runs $bad"; done
wt_line=$(grep -n "worktree remove" "$T/clean.sh" | cut -d: -f1); br_line=$(grep -n "branch -d" "$T/clean.sh" | cut -d: -f1)
assert_eq yes "$([ "$wt_line" -lt "$br_line" ] && echo yes || echo no)" "worktree goes before its branch"
assert_eq yes "$([ -d "$WT" ] && [ -f "$F/e2e/auth.json" ] && echo yes || echo no)" "planning deletes nothing"

touch "$WT/dirty.txt"
assert_contains "uncommitted changes" "$(bash "$CP" "$F" 2>&1)" "dirty worktree is kept"
rm "$WT/dirty.txt"

ticket review
out=$(bash "$CP" "$F" 2>&1)
assert_not_contains "WORKTREE" "$out" "ticket in review keeps its worktree"
assert_contains "1 trace/video file(s)" "$out" "traces stay until the ticket is done"
assert_contains "ticket not done (or add --done)" "$out" "the kept-trace line says why"
assert_contains "SECURITY" "$out" "session file is flagged at any stage"

assert_contains "SECURITY" "$(bash "$CP" --all 2>&1)" "--all scans every task folder"