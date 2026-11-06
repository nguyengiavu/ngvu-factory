source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T"
R="$T/repo"; BM="$KF_S/blocker-merged.sh"
E=ngvu/vung-10/EPIC-e; C1=ngvu/vung-10/vung-11-a; C2=ngvu/vung-10/vung-12-b

# History inherited from master must never count: an old branch of VUNG-77 merged into master.
git -C "$R" checkout -q -b ngvu/vung-77-old master && git -C "$R" commit -q --allow-empty -m "VUNG-77: old work"
git -C "$R" checkout -q master && git -C "$R" merge -q --no-ff ngvu/vung-77-old -m "Merged in ngvu/vung-77-old (pull request #9)" && git -C "$R" push -q origin master 2>/dev/null

assert_exit 12 "epic branch missing on origin" bash "$BM" "$R" "$E" "$C1"
git -C "$R" checkout -q -b "$E" master && git -C "$R" commit -q --allow-empty -m "epic setup" && git -C "$R" push -q origin "$E" 2>/dev/null

# A child branch freshly created from the epic, with no commits yet, is not merged.
git -C "$R" branch "$C1" "origin/$E"
assert_exit 11 "fresh child branch without commits is not merged" bash "$BM" "$R" "$E" "$C1"
assert_exit 11 "key mode: child without commits is not merged" bash "$BM" "$R" "$E" VUNG-11

git -C "$R" checkout -q "$C1" && git -C "$R" commit -q --allow-empty -m "VUNG-11: a"
assert_exit 11 "child with unmerged commits is not merged" bash "$BM" "$R" "$E" "$C1"

git -C "$R" checkout -q "$E" && git -C "$R" merge -q --no-ff "$C1" -m "Merged in $C1 (pull request #1)" && git -C "$R" push -q origin "$E" 2>/dev/null
assert_exit 0 "child merged" bash "$BM" "$R" "$E" "$C1"
assert_exit 0 "key mode: child merged" bash "$BM" "$R" "$E" VUNG-11

git -C "$R" checkout -q -b "$C2" "$E" && git -C "$R" commit -q --allow-empty -m "VUNG-12: b"
git -C "$R" checkout -q "$E" && git -C "$R" merge -q --no-ff "$C2" -m "Merged in $C2 (pull request #2)" && git -C "$R" push -q origin "$E" 2>/dev/null
git -C "$R" branch -q -D "$C2"
assert_exit 0 "deleted source branch still detected" bash "$BM" "$R" "$E" "$C2"
assert_exit 11 "key mode: unknown key not merged" bash "$BM" "$R" "$E" VUNG-99
assert_exit 11 "key mode: master history does not count" bash "$BM" "$R" "$E" VUNG-77
assert_exit 11 "deleted branch without trace not merged" bash "$BM" "$R" "$E" ngvu/vung-10/vung-13-c
assert_exit 1 "branch without a vung key rejected" bash "$BM" "$R" "$E" some-branch
# Merged straight to master after the epic branched: done, but not in the epic (exit 23, F1).
git -C "$R" checkout -q -b ngvu/vung-14-direct master && git -C "$R" commit -q --allow-empty -m "VUNG-14: direct"
git -C "$R" checkout -q master && git -C "$R" merge -q --no-ff ngvu/vung-14-direct -m "Merged in ngvu/vung-14-direct (pull request #3)" && git -C "$R" push -q origin master 2>/dev/null
assert_exit 23 "key mode: merged to master after the epic branched" bash "$BM" "$R" "$E" VUNG-14
assert_exit 0 "a child merged into the epic still wins over master" bash "$BM" "$R" "$E" VUNG-11
assert_exit 11 "key mode: master history from before the epic still does not count" bash "$BM" "$R" "$E" VUNG-77
# GitHub merge commits ("Merge pull request #N from owner/branch") count like the Bitbucket form.
C3=ngvu/vung-10/vung-15-gh; MM="$KF_S/merged-to-master.sh"
git -C "$R" checkout -q -b "$C3" "$E" && git -C "$R" commit -q --allow-empty -m "work for the gh child"
assert_exit 11 "github: child with unmerged commits is not merged" bash "$BM" "$R" "$E" VUNG-15
git -C "$R" checkout -q "$E" && git -C "$R" merge -q --no-ff "$C3" -m "Merge pull request #4 from someone/$C3" && git -C "$R" push -q origin "$E" 2>/dev/null
git -C "$R" branch -q -D "$C3"
assert_exit 0 "github: merge commit detected, source branch deleted" bash "$BM" "$R" "$E" VUNG-15
git -C "$R" checkout -q -b ngvu/vung-16-gh master && git -C "$R" commit -q --allow-empty -m "gh direct"
git -C "$R" checkout -q master && git -C "$R" merge -q --no-ff ngvu/vung-16-gh -m "Merge pull request #5 from someone/ngvu/vung-16-gh" && git -C "$R" push -q origin master 2>/dev/null
assert_exit 23 "github: merged to master after the epic branched" bash "$BM" "$R" "$E" VUNG-16
assert_exit 0 "merged-to-master finds a github merge commit" bash "$MM" "$R" VUNG-16
assert_exit 0 "merged-to-master finds a bitbucket merge commit" bash "$MM" "$R" VUNG-14
assert_exit 11 "merged-to-master: unknown key" bash "$MM" "$R" VUNG-99
kf_finish
