source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; U="$KF_S/unit-test.sh"; mkdir -p "$T/wt"
printf '@echo off
echo BUILD SUCCESS from %%CD%%
exit /b 0
' > "$T/ok.bat"
printf '@echo off
echo BUILD FAILURE
exit /b 3
' > "$T/bad.bat"
cfg() { sed "s#\"unitTestScript\": \"[^\"]*\"#\"unitTestScript\": \"$(cygpath -m "$T/$1")\"#" "$T/factory.config.json" > "$T/c-$1.json"; echo "$T/c-$1.json"; }
out=$(KF_CONFIG=$(cfg ok.bat) bash "$U" "$T/wt" 2>&1); rc=$?
assert_eq 0 "$rc" "unit-test.sh passes the script exit code (M5)"
assert_contains "BUILD SUCCESS" "$out" "unit-test.sh runs the configured script (M5)"
assert_contains "wt" "$out" "unit-test.sh runs in the worktree (M5)"
KF_CONFIG=$(cfg bad.bat) bash "$U" "$T/wt" >/dev/null 2>&1; assert_eq 3 "$?" "unit-test.sh propagates failure (M5)"
assert_exit 1 "unit-test.sh rejects a missing worktree (M5)" bash "$U" "$T/nope"
kf_finish
