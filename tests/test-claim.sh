source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; F="$T/epic/factory"; mkdir -p "$F"
assert_exit 0 "first claim wins" bash "$KF_S/claim.sh" "$F" VUNG-1
assert_exit 10 "second claim refused" bash "$KF_S/claim.sh" "$F" VUNG-1
assert_exit 0 "release own claim (M1)" bash "$KF_S/claim.sh" --release "$F" VUNG-1
assert_exit 0 "claim again after release (M1)" bash "$KF_S/claim.sh" "$F" VUNG-1
assert_exit 18 "release of an unclaimed key (M1)" bash "$KF_S/claim.sh" --release "$F" VUNG-9
assert_exit 1 "bad key refused" bash "$KF_S/claim.sh" "$F" vung-2
: > "$T/wins"
for i in 1 2 3 4 5; do (bash "$KF_S/claim.sh" "$F" VUNG-2 >/dev/null 2>&1 && echo ok >> "$T/wins") & done
wait
assert_eq 1 "$(wc -l < "$T/wins" | tr -d ' ')" "exactly one of 5 parallel claims wins"
kf_finish
