#!/usr/bin/env bash
# Resolve a repo name to its main checkout under config paths.repoRoots ({path, kind} objects)
# and print "<path><TAB><kind>" for each match (a directory with a .git entry).
# Usage: repo-path.sh <repo-name>
# Exit: 0 one match, 3 none, 4 several (all printed), 1 usage or config error.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

name="${1:-}"
[[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || kf_die "usage: repo-path.sh <repo-name> (a name, not a path)"
py="$(kf_python)" || exit 1
cfg="$(kf_config_path)" || exit 1
# Python only reads the config; bash tests the paths (native Windows Python cannot see /tmp/...).
roots="$("$py" -c '
import json, sys
roots = json.load(open(sys.argv[1], encoding="utf-8-sig")).get("paths", {}).get("repoRoots")
if not roots or not all(isinstance(r, dict) and "path" in r and "kind" in r for r in roots):
    sys.exit(1)
for r in roots: print("%s\t%s" % (r["path"], r["kind"]))
' "$(kf_native_path "$cfg")" | tr -d '\r')" || kf_die "config paths.repoRoots must be a list of {path, kind}"

count=0
while IFS=$'\t' read -r root kind; do
  [ -e "$root/$name/.git" ] || continue
  printf '%s\t%s\n' "$root/$name" "$kind"
  count=$((count+1))
done <<< "$roots"

[ "$count" -eq 1 ] && exit 0
[ "$count" -eq 0 ] && exit 3
exit 4
