source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; SC="$KF_S/state-check.sh"
cat > "$T/t.json" <<'EOF'
{ "key": "VUNG-000011", "summary": "s", "epic": null, "folder": "VUNG-000011-x", "slug": "x",
  "repos": [ { "repo": "example_core", "owner": "ngvu", "worktree": "D:/w", "branch": "ngvu/vung-000011-x", "base": "origin/master" } ],
  "stage": "review", "round": 1, "resumesLeft": 2,
  "reviews": { "securityTenancy": "PASS", "codeConventions": "pending", "contractIntegration": "CHANGES", "dataPersistence": "pending" },
  "intakeApproved": true, "updatedAt": "2026-10-15T10:00:00Z" }
EOF
assert_exit 0 "valid ticket" bash "$SC" ticket "$T/t.json"
sed 's/"review"/"merged"/' "$T/t.json" > "$T/t2.json"; assert_exit 2 "unknown stage" bash "$SC" ticket "$T/t2.json"
sed 's/"PASS"/"OK"/' "$T/t.json" > "$T/t3.json"; assert_exit 2 "unknown review value" bash "$SC" ticket "$T/t3.json"
sed 's/"key": "VUNG-000011"/"key": "100001"/' "$T/t.json" > "$T/t4.json"; assert_exit 2 "bad key" bash "$SC" ticket "$T/t4.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "builderAgentId": "a0f43e49",/' "$T/t.json" > "$T/t6.json"; assert_exit 0 "builderAgentId string accepted (P-a)" bash "$SC" ticket "$T/t6.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "builderAgentId": 7,/' "$T/t.json" > "$T/t7.json"; assert_exit 2 "builderAgentId must be a string (P-a)" bash "$SC" ticket "$T/t7.json"
sed 's/"stage": "review"/"stage": "closed", "closedReason": "duplicate of VUNG-000012"/' "$T/t.json" > "$T/t8.json"; assert_exit 0 "closed with reason" bash "$SC" ticket "$T/t8.json"
sed 's/"stage": "review"/"stage": "closed"/' "$T/t.json" > "$T/t9.json"; assert_exit 2 "closed needs closedReason" bash "$SC" ticket "$T/t9.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "openQuestionsAccepted": ["Q12", "Q14"],/' "$T/t.json" > "$T/t10.json"; assert_exit 0 "openQuestionsAccepted list" bash "$SC" ticket "$T/t10.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "openQuestionsAccepted": "Q12",/' "$T/t.json" > "$T/t11.json"; assert_exit 2 "openQuestionsAccepted must be a list" bash "$SC" ticket "$T/t11.json"
sed 's/"stage": "review"/"stage": "verified"/' "$T/t.json" > "$T/t12.json"; assert_exit 0 "verified stage" bash "$SC" ticket "$T/t12.json"
sed 's/"repo": "example_core",/"repo": "example_next", "kind": "nextjs",/' "$T/t.json" > "$T/t13.json"; assert_exit 0 "repo kind nextjs" bash "$SC" ticket "$T/t13.json"
sed 's/"repo": "example_core",/"repo": "example_next", "kind": "ivy",/' "$T/t.json" > "$T/t13b.json"; assert_exit 2 "repo kind ivy is rejected" bash "$SC" ticket "$T/t13b.json"
sed 's/"repo": "example_core",/"repo": "example_core", "kind": "python",/' "$T/t.json" > "$T/t14.json"; assert_exit 2 "unknown repo kind" bash "$SC" ticket "$T/t14.json"
sed 's/"dataPersistence": "pending"/"dataPersistence": "pending", "frontendUi": "n\/a"/' "$T/t.json" > "$T/t15.json"; assert_exit 0 "frontendUi n/a" bash "$SC" ticket "$T/t15.json"
sed 's/"dataPersistence": "pending"/"dataPersistence": "pending", "frontendUi": "skip"/' "$T/t.json" > "$T/t16.json"; assert_exit 2 "frontendUi bad value" bash "$SC" ticket "$T/t16.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "prLinks": {"example_core": "https:\/\/github.com\/x"},/' "$T/t.json" > "$T/t17.json"; assert_exit 0 "prLinks object" bash "$SC" ticket "$T/t17.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "prLinks": ["x"],/' "$T/t.json" > "$T/t18.json"; assert_exit 2 "prLinks must be an object" bash "$SC" ticket "$T/t18.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "epicFolder": "EPIC-VUNG-000010-e", "story": "S3",/' "$T/t.json" > "$T/t19.json"; assert_exit 0 "epic child records epicFolder and story" bash "$SC" ticket "$T/t19.json"
sed 's/"intakeApproved": true,/"intakeApproved": true, "story": "3",/' "$T/t.json" > "$T/t20.json"; assert_exit 2 "story must be S<n>" bash "$SC" ticket "$T/t20.json"
echo '{ broken' > "$T/t5.json"; assert_exit 2 "not JSON" bash "$SC" ticket "$T/t5.json"
cat > "$T/e.json" <<'EOF'
{ "key": "VUNG-000010", "summary": "s", "folder": "VUNG-000010-e", "slug": "e", "repos": ["example_core"],
  "epicBranch": "ngvu/vung-000010/EPIC-e", "intakeApproved": false,
  "children": [ { "key": "VUNG-000011", "summary": "a", "folder": "VUNG-000011-x", "blockedBy": [], "externalBlockers": [], "state": "queued" },
                { "key": "VUNG-000012", "summary": "b", "folder": null, "blockedBy": ["VUNG-000011"], "externalBlockers": [], "state": "needs-investigation" } ],
  "updatedAt": "2026-10-15T10:00:00Z" }
EOF
assert_exit 0 "valid epic" bash "$SC" epic "$T/e.json"
sed 's/"needs-investigation"/"done"/' "$T/e.json" > "$T/e2.json"; assert_exit 2 "unknown child state" bash "$SC" epic "$T/e2.json"
kf_finish
