#!/usr/bin/env bash
# Owners of a service repo from catalog-info.yaml, alias-mapped.
# Usage: owner.sh [--is-own] <repo-dir>
# Exit: 0 ok (and own, with --is-own), 14 a foreign owner is present (--is-own), 15 no catalog or no owner, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

mode=print
[ "${1:-}" = "--is-own" ] && { mode=own; shift; }
repo="${1:-}"
[ -n "$repo" ] || kf_die "usage: owner.sh [--is-own] <repo-dir>"
cat="$repo/catalog-info.yaml"
[ -f "$cat" ] || { echo "no catalog-info.yaml in $repo" >&2; exit 15; }
py="$(kf_python)" || exit 1
cfg="$(kf_config_path)" || exit 1

"$py" -c '
import json, re, sys
cfg = json.load(open(sys.argv[1], encoding="utf-8-sig"))
aliases = {k.lower(): v.lower() for k, v in cfg.get("legacyOwnerAliases", {}).items()}
own = {t.lower() for t in cfg.get("ownTeams", [])}
owners = set()
for line in open(sys.argv[2], encoding="utf-8-sig"):
    m = re.match(r"""\s*owner:\s*["\x27]?([^"\x27#\s]+)["\x27]?\s*(#.*)?$""", line)
    if m:
        o = m.group(1).strip().lower().split("/")[-1].split(":")[-1]
        owners.add(aliases.get(o, o))
if not owners:
    sys.exit(15)
print("\n".join(sorted(owners)))
if sys.argv[3] == "own":
    sys.exit(0 if owners <= own else 14)
' "$(kf_native_path "$cfg")" "$(kf_native_path "$cat")" "$mode" | tr -d '\r'
