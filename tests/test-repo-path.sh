source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; RP="$KF_S/repo-path.sh"
mkdir -p "$T/services/example_core/.git" "$T/nextjs/example_next/.git" "$T/services/dup/.git" "$T/nextjs/dup/.git" "$T/services/nogit"

out=$(bash "$RP" example_core); rc=$?
assert_eq 0 "$rc" "one match exits 0"
assert_eq "$T/services/example_core	java-service" "$out" "prints the services checkout and its kind"
assert_eq "$T/nextjs/example_next	nextjs" "$(bash "$RP" example_next)" "second root is searched, kind nextjs"
out=$(bash "$RP" dup); rc=$?
assert_eq 4 "$rc" "two matches exit 4"
assert_contains "$T/nextjs/dup" "$out" "every match printed"
assert_exit 3 "missing repo exits 3" bash "$RP" nope
assert_exit 3 "directory without .git is not a repo" bash "$RP" nogit
assert_exit 1 "path traversal rejected" bash "$RP" ../x
assert_exit 1 "empty name rejected" bash "$RP"
kf_finish
