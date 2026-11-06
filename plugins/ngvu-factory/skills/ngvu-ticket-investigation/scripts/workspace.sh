# Sourced by the investigation scripts: sets ROOT (workspace) and TASKS (task folders), from
#   1. NGVU_WORKSPACE or NGVU_ROOT (TASKS = $ROOT/tasks)
#   2. the factory config: "workspace" and "paths.tasks" (machine.json, written by deploy/bootstrap)
#   3. D:/workspace
# A script's --root <dir> then sets ROOT=<dir>, TASKS=<dir>/tasks; --tasks <dir> sets TASKS only.
ROOT="${NGVU_WORKSPACE:-${NGVU_ROOT:-}}"; TASKS=""
_ws_lib="$(dirname "${BASH_SOURCE[0]}")/../../ngvu-factory/scripts/lib.sh"
if [ -z "$ROOT" ] && [ -f "$_ws_lib" ]; then
  source "$_ws_lib"
  ROOT="$(kf_cfg workspace 2>/dev/null || true)"; TASKS="$(kf_cfg paths.tasks 2>/dev/null || true)"
fi
ROOT="${ROOT:-D:/workspace}"; TASKS="${TASKS:-$ROOT/tasks}"
unset _ws_lib
