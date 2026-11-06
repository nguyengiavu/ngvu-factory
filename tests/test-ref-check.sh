source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T"
R="$T/repo"; C="$KF_S/ref-check.sh"
git -C "$R" branch ngvu/vung-1-x
git -C "$R" branch ngvu/vung-2 && git -C "$R" push -q origin ngvu/vung-2 2>/dev/null && git -C "$R" branch -q -D ngvu/vung-2
git -C "$R" fetch -q origin
git -C "$R" branch ngvu/vung-3/EPIC-z

assert_exit 0 "free name" bash "$C" "$R" ngvu/vung-9-free
assert_exit 5 "local branch exists" bash "$C" "$R" ngvu/vung-1-x
assert_exit 5 "origin branch exists" bash "$C" "$R" ngvu/vung-2
assert_exit 6 "parent path is a branch on origin" bash "$C" "$R" ngvu/vung-2/EPIC-y
assert_exit 6 "child path already exists under the name" bash "$C" "$R" ngvu/vung-3
assert_exit 1 "missing args" bash "$C" "$R"
kf_finish
