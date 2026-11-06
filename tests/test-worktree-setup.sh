source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T"
R="$T/repo"; W="$KF_S/worktree-setup.sh"; CB="$KF_S/create-branch.sh"
master_sha=$(git -C "$R" rev-parse origin/master)

out=$(bash "$W" "$R" ngvu/vung-1-a origin/master "$T/wt/VUNG-1/repo"); rc=$?
assert_eq 0 "$rc" "worktree created"
assert_eq "$T/wt/VUNG-1/repo" "$out" "prints worktree path"
assert_eq "ngvu/vung-1-a" "$(git -C "$T/wt/VUNG-1/repo" branch --show-current)" "worktree on new branch"
assert_eq "$master_sha" "$(git -C "$T/wt/VUNG-1/repo" rev-parse HEAD)" "branch starts at base"
assert_eq "" "$(git -C "$R" config --get branch.ngvu/vung-1-a.remote)" "branch has no upstream"

assert_exit 9 "existing worktree path refused" bash "$W" "$R" ngvu/vung-2-b origin/master "$T/wt/VUNG-1/repo"
assert_exit 5 "existing branch refused" bash "$W" "$R" ngvu/vung-1-a origin/master "$T/wt/other"
assert_exit 8 "missing base refused" bash "$W" "$R" ngvu/vung-3-c origin/nope "$T/wt/VUNG-3/repo"

assert_exit 0 "epic branch created" bash "$CB" "$R" ngvu/vung-10/EPIC-e origin/master
assert_eq "$master_sha" "$(git -C "$R" rev-parse ngvu/vung-10/EPIC-e)" "epic branch at base"
assert_exit 5 "epic branch twice refused" bash "$CB" "$R" ngvu/vung-10/EPIC-e origin/master
assert_exit 0 "child worktree from local epic branch" bash "$W" "$R" ngvu/vung-10/vung-11-x ngvu/vung-10/EPIC-e "$T/wt/VUNG-11/repo"

git -C "$R" remote set-url origin "$T/does-not-exist.git"
assert_exit 7 "fetch failure reported" bash "$W" "$R" ngvu/vung-4-d origin/master "$T/wt/VUNG-4/repo"
kf_finish
