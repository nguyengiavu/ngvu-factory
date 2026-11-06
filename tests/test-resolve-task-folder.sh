source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; tasks="$T/tasks"
mkdir -p "$tasks/VUNG-100001-example-ticket" "$tasks/EPIC-VUNG-100002" \
         "$tasks/VUNG-100002-example-epic" "$tasks/VUNG-1000010-other" "$tasks/VUNG-100011"
TAB=$'\t'

out=$(bash "$KF_S/resolve-task-folder.sh" 100001); rc=$?
assert_eq 0 "$rc" "one match exits 0"
assert_eq "VUNG-100001-example-ticket${TAB}example-ticket" "$out" "prints folder and slug; ignores VUNG-1000010"

out=$(bash "$KF_S/resolve-task-folder.sh" 100002); rc=$?
assert_eq 4 "$rc" "two matches exit 4"
assert_contains "EPIC-VUNG-100002${TAB}" "$out" "EPIC folder listed with empty slug"
assert_contains "VUNG-100002-example-epic${TAB}example-epic" "$out" "VUNG folder listed"

out=$(bash "$KF_S/resolve-task-folder.sh" 100011)
assert_eq "VUNG-100011${TAB}" "$out" "folder without slug"

assert_exit 3 "no match exits 3" bash "$KF_S/resolve-task-folder.sh" 999999
assert_exit 1 "non-numeric key rejected" bash "$KF_S/resolve-task-folder.sh" abc
out=$(bash "$KF_S/resolve-task-folder.sh" 100001 "$tasks")
assert_eq "VUNG-100001-example-ticket${TAB}example-ticket" "$out" "explicit tasks dir argument"
kf_finish
