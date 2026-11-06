# Shared helpers for ngvu-factory scripts. Source it; do not execute.
KF_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kf_die() { echo "ngvu-factory: $*" >&2; exit 1; }

# Config: KF_CONFIG wins. Otherwise the bundled <skill>/factory.config.json, with the machine
# overlay (KF_MACHINE_CONFIG, default ~/.claude/ngvu-factory/machine.json) merged over it: objects
# merge key by key, any other value replaces. The overlay survives plugin updates; the merged
# result is written next to it and its path is printed.
kf_config_path() {
  if [ -n "${KF_CONFIG:-}" ]; then echo "$KF_CONFIG"; return 0; fi
  local base="" p
  for p in "$KF_SCRIPTS_DIR/../factory.config.json"; do
    [ -f "$p" ] && { base="$p"; break; }
  done
  [ -n "$base" ] || { echo "ngvu-factory: factory.config.json not found (set KF_CONFIG)" >&2; return 1; }
  local ov="${KF_MACHINE_CONFIG:-$HOME/.claude/ngvu-factory/machine.json}"
  [ -f "$ov" ] || { echo "$base"; return 0; }
  local py out="${ov%.json}.merged.json"
  py="$(kf_python)" || return 1
  "$py" -c '
import json, os, sys
def merge(a, b):
    for k, v in b.items():
        a[k] = merge(a[k], v) if isinstance(v, dict) and isinstance(a.get(k), dict) else v
    return a
base = json.load(open(sys.argv[1], encoding="utf-8-sig"))
try:
    ov = json.load(open(sys.argv[2], encoding="utf-8-sig"))
except ValueError as e:
    sys.exit("ngvu-factory: machine config %s is not valid JSON: %s" % (sys.argv[2], e))
if not isinstance(ov, dict): sys.exit("ngvu-factory: machine config must be a JSON object")
tmp = "%s.%d" % (sys.argv[3], os.getpid())
with open(tmp, "w", encoding="utf-8") as f: json.dump(merge(base, ov), f, indent=2)
os.replace(tmp, sys.argv[3])
' "$(kf_native_path "$base")" "$(kf_native_path "$ov")" "$(kf_native_path "$out")" || return 1
  echo "$out"
}

# Native Windows Python cannot open /tmp/... or /d/...; convert when cygpath exists.
kf_native_path() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi; }

# python3 is a Microsoft Store stub on some machines, so probe each candidate.
kf_python() {
  local c
  for c in "${KF_PYTHON:-}" python python3 py; do
    [ -n "$c" ] || continue
    "$c" -c 'import sys' >/dev/null 2>&1 && { echo "$c"; return 0; }
  done
  echo "ngvu-factory: no working python found (set KF_PYTHON)" >&2
  return 1
}

# kf_cfg <dotted.key>: print a config value; lists one item per line; exit 3 if missing.
kf_cfg() {
  local py cfg
  py="$(kf_python)" || return 1
  cfg="$(kf_config_path)" || return 1
  "$py" -c '
import json, sys
v = json.load(open(sys.argv[1], encoding="utf-8-sig"))
for k in sys.argv[2].split("."):
    if not isinstance(v, dict) or k not in v:
        sys.exit(3)
    v = v[k]
if isinstance(v, list):
    print("\n".join(str(x) for x in v))
elif isinstance(v, dict):
    print(json.dumps(v))
else:
    print(v)
' "$(kf_native_path "$cfg")" "$1" | tr -d '\r'
}
