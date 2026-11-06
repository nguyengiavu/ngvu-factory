#!/usr/bin/env bash
# Order epic children so blockers come first; ties keep Jira order.
# Usage: queue-order.sh <epic.json>     Exit: 0 ok, 17 dependency cycle, 2 invalid file, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

f="${1:-}"
[ -n "$f" ] || kf_die "usage: queue-order.sh <epic.json>"
[ -f "$f" ] || { echo "missing: $f" >&2; exit 2; }
py="$(kf_python)" || exit 1
"$py" -c '
import json, sys
try:
    kids = json.load(open(sys.argv[1], encoding="utf-8-sig"))["children"]
except Exception as e:
    print("invalid epic.json: %s" % e, file=sys.stderr); sys.exit(2)
keys = [c["key"] for c in kids]
deps = {c["key"]: [b for b in c.get("blockedBy", []) if b in keys] for c in kids}
done, out = set(), []
while len(out) < len(keys):
    ready = [k for k in keys if k not in done and all(b in done for b in deps[k])]
    if not ready:
        print("dependency cycle among: " + ", ".join(k for k in keys if k not in done), file=sys.stderr)
        sys.exit(17)
    done.add(ready[0]); out.append(ready[0])
print("\n".join(out))
' "$(kf_native_path "$f")" | tr -d '\r'
