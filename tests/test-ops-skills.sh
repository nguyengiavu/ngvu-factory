source "$(dirname "$0")/lib/assert.sh"
# ngvu-flow-logs and ngvu-pod-health: read-only, bounded, and they refuse unsafe input (dry run, no cloud calls).
FL="$KF_ROOT/plugins/ngvu-engineering/skills/ngvu-flow-logs/trace_flow_logs.sh"
PH="$KF_ROOT/plugins/ngvu-engineering/skills/ngvu-pod-health/pod_health.sh"
dry() { KF_DRY_RUN=1 env "$@"; }

out=$(dry ENV=dev SERVICES="web docs" SEVERITY=ERROR SEARCH='req "42"' bash "$FL")
assert_contains 'resource.labels.namespace_name=\"dev\"' "$out" "flow-logs filters the namespace"
assert_contains 'container_name=\"web\"' "$out" "flow-logs includes the first service"
assert_contains 'container_name=\"docs\"' "$out" "flow-logs includes the second service"
assert_contains 'severity\>=ERROR' "$out" "flow-logs applies the severity"
assert_contains '--order=asc' "$out" "flow-logs merges oldest first"
assert_contains '--limit=200' "$out" "flow-logs has a default limit"
assert_contains 'SEARCH\(\"req\ \\\"42\\\"\"\)' "$out" "flow-logs escapes quotes in SEARCH"
assert_not_contains 'logging write' "$out" "flow-logs never writes"

assert_exit 1 "flow-logs: ENV required" env -u ENV SERVICES=web bash "$FL"
assert_exit 1 "flow-logs: SERVICES required" env ENV=dev bash "$FL"
assert_exit 1 "flow-logs: bad service name" dry ENV=dev 'SERVICES=web;rm' bash "$FL"
assert_exit 1 "flow-logs: bad severity" dry ENV=dev SERVICES=web SEVERITY=LOUD bash "$FL"
assert_exit 1 "flow-logs: limit above 5000" dry ENV=dev SERVICES=web LIMIT=5001 bash "$FL"
assert_exit 0 "flow-logs: limit 5000 allowed" dry ENV=dev SERVICES=web LIMIT=5000 bash "$FL"
assert_exit 1 "flow-logs: window above 31 days" dry ENV=dev SERVICES=web WINDOW_HOURS=745 bash "$FL"
assert_exit 0 "flow-logs: window of 31 days allowed" dry ENV=dev SERVICES=web WINDOW_HOURS=744 bash "$FL"
assert_exit 1 "flow-logs: explicit range above 31 days" dry ENV=dev SERVICES=web FROM=2026-01-01T00:00:00Z TO=2026-03-01T00:00:00Z bash "$FL"
assert_exit 1 "flow-logs: prod needs confirmation" dry ENV=prod SERVICES=web bash "$FL"
assert_exit 0 "flow-logs: prod with confirmation" dry ENV=prod CONFIRM_PROD=1 SERVICES=web bash "$FL"

out=$(dry ENV=dev KUBE_CONTEXT=c1 SERVICES="example-docs" bash "$PH")
assert_contains "kubectl --context c1 -n dev get pods" "$out" "pod-health lists pods in the namespace"
assert_contains "get deployments" "$out" "pod-health lists deployments"
assert_contains "type=Warning" "$out" "pod-health reads Warning events"
for verb in delete scale patch apply exec "rollout restart" edit; do
  assert_not_contains "$verb" "$out" "pod-health never runs '$verb'"
done
assert_exit 1 "pod-health: KUBE_CONTEXT required" dry ENV=dev bash "$PH"
assert_exit 1 "pod-health: ENV required" dry -u ENV KUBE_CONTEXT=c1 bash "$PH"
assert_exit 1 "pod-health: bad service name" dry ENV=dev KUBE_CONTEXT=c1 'SERVICES=a b;c' bash "$PH"
assert_exit 1 "pod-health: prod needs confirmation" dry ENV=prod KUBE_CONTEXT=c1 bash "$PH"
assert_exit 0 "pod-health: prod with confirmation" dry ENV=prod CONFIRM_PROD=1 KUBE_CONTEXT=c1 bash "$PH"

for n in playwright-checking; do
  body=$(cat "$KF_ROOT/plugins/ngvu-engineering/skills/$n/SKILL.md")
  assert_contains "Dev or test environments and test accounts only" "$body" "$n is limited to dev/test"
  assert_contains "NOT RUN" "$body" "$n never reports unchecked scenarios as PASS"
done
kf_finish
