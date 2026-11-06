source "$(dirname "$0")/lib/assert.sh"
# The kit is cloned by every team to any folder: shipped text names config keys and placeholders
# (<workspace>, <tasks>, <team>), never one machine's paths, the legacy /kf command or personal items.
cd "$KF_ROOT" || exit 1
CURRENT=(plugins guide README.md AUTHORS.md deploy/README.md presentation/index.html
         docs/ARCHITECTURE.md docs/WORKFLOW-TICKET.md docs/WORKFLOW-EPIC.md docs/AGENTS-AND-GATES.md docs/COST.md)
# Fixtures and defaults that must stay literal.
SKIP='factory\.config\.json|/workspace\.sh|/new-report\.sh|guard-cases\.tsv|ngvu_guardrails\.py|/evals/|/selftest\.sh'
scan() { grep -rnIE "$1" "${CURRENT[@]}" 2>/dev/null | grep -vE "$SKIP" | grep -viE "${2:-^$}"; }

hits=$(scan 'D:[\\/]+workspace|/d/workspace' 'default|e\.g\.')
assert_eq "" "$hits" "machine paths only as a labelled default"
assert_eq "" "$(scan '(^|[ `(])/kf( |`|$)' 'legacy')" "no legacy /kf command outside a 'legacy' note"
assert_eq "" "$(scan 'C:\\Users\\|D:\\(S[t]udy|obsidian)|i[u]h-|software-factory-claude-code[\\/]' )" "no personal paths or private skills"
assert_eq "" "$(grep -rn 'i[u]h-' config deploy/kit.json)" "no personal skill overrides in shared config"

# Investigation scripts resolve the task folder from the machine config, then env, then --root.
T=$(kf_tmp); WS="$KF_ROOT/plugins/ngvu-factory/skills/ngvu-ticket-investigation/scripts/workspace.sh"
printf '{"workspace": "%s/ws", "paths": {"tasks": "%s/my-tasks"}}' "$T" "$T" > "$T/m.json"
r() { env -u KF_CONFIG -u NGVU_WORKSPACE -u NGVU_ROOT "$@" bash -c "source '$WS'; echo \"\$ROOT|\$TASKS\""; }
assert_eq "$T/ws|$T/my-tasks" "$(r KF_MACHINE_CONFIG="$T/m.json")" "machine config workspace and paths.tasks"
assert_eq "$T/e|$T/e/tasks" "$(r KF_MACHINE_CONFIG="$T/m.json" NGVU_WORKSPACE="$T/e")" "NGVU_WORKSPACE wins"
mkdir -p "$T/my-tasks"
env -u KF_CONFIG KF_MACHINE_CONFIG="$T/m.json" bash "$(dirname "$WS")/new-task.sh" 900100 demo >/dev/null 2>&1
assert_eq yes "$([ -d "$T/my-tasks/VUNG-900100-demo" ] && echo yes || echo no)" "new-task writes into config paths.tasks"
kf_finish
