source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; Q="$KF_S/queue-order.sh"
mk() { # mk <file> <children-json>
  printf '{ "key": "VUNG-000010", "summary": "s", "folder": "f", "slug": "e", "repos": [], "epicBranch": "b", "intakeApproved": true, "children": %s, "updatedAt": "x" }' "$2" > "$1"; }
c() { printf '{ "key": "%s", "summary": "", "folder": null, "blockedBy": [%s], "externalBlockers": [], "state": "queued" }' "$1" "$2"; }
mk "$T/a.json" "[ $(c VUNG-3 '"VUNG-1"'), $(c VUNG-1 ''), $(c VUNG-2 '"VUNG-3"') ]"
assert_eq "VUNG-1
VUNG-3
VUNG-2" "$(bash "$Q" "$T/a.json")" "blockers first"
mk "$T/b.json" "[ $(c VUNG-2 ''), $(c VUNG-1 '') ]"
assert_eq "VUNG-2
VUNG-1" "$(bash "$Q" "$T/b.json")" "independent children keep Jira order"
mk "$T/c.json" "[ $(c VUNG-1 '"VUNG-2"'), $(c VUNG-2 '"VUNG-1"'), $(c VUNG-3 '') ]"
assert_exit 17 "cycle detected" bash "$Q" "$T/c.json"
kf_finish
