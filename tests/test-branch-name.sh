source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"
B="$KF_S/branch-name.sh"
assert_eq "ngvu/vung-100001-example-ticket" "$(bash "$B" ticket 100001 example-ticket)" "standalone ticket"
assert_eq "ngvu/vung-100002/EPIC-example-epic" "$(bash "$B" epic 100002 example-epic)" "epic"
assert_eq "ngvu/vung-100002/vung-100001-example-ticket" "$(bash "$B" child 100002 100001 example-ticket)" "epic child"
assert_exit 1 "upper-case or underscore slug rejected" bash "$B" ticket 1 Payer_API
assert_exit 1 "trailing dash rejected" bash "$B" ticket 1 payer-
assert_exit 1 "non-numeric key rejected" bash "$B" ticket VUNG-1 x
assert_exit 1 "unknown kind rejected" bash "$B" story 1 x
assert_exit 1 "missing args rejected" bash "$B" child 1 2
kf_finish
