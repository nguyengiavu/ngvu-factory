#!/usr/bin/env bash
# epic-children.sh — inventory an epic on Jira through acli (READ ONLY): the epic, every child ticket, the links between them.
#
#   bash epic-children.sh <epic-number> [> evidence/E0-jira-inventory.md]
#
# Prints a Markdown table: Key | Type | Status | Summary | Blocked by | Blocks | Other links.
# "Blocked by" = a "Blocks" link that has an inwardIssue (same convention as /ngvu-factory epic).
# Exit: 0 ok · 2 acli not logged in/error · 4 not an Epic · 1 usage.
set -uo pipefail

N="${1#VUNG-}"; N="${N#vung-}"
[[ "$N" =~ ^[0-9]+$ ]] || { sed -n '2,8p' "$0" >&2; exit 1; }
command -v acli >/dev/null 2>&1 || { echo "acli not found; see ngvu-ticket-investigation/references/jira-and-sources.md" >&2; exit 2; }
acli jira auth status >/dev/null 2>&1 || { echo "acli is not logged in: ask the user to run 'acli jira auth login'" >&2; exit 2; }
py=""; for c in "${KF_PYTHON:-}" python python3 py; do [ -n "$c" ] && "$c" -c 'import sys' >/dev/null 2>&1 && { py="$c"; break; }; done
[ -n "$py" ] || { echo "python not found" >&2; exit 1; }
native() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi; }

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
acli jira workitem view "VUNG-$N" --fields 'summary,issuetype,status' --json > "$T/epic.json" 2>"$T/err" \
  || { cat "$T/err" >&2; exit 2; }
acli jira workitem search --jql "parent = VUNG-$N ORDER BY Rank ASC" \
  --fields 'key,summary,status,issuetype' --limit 200 --json > "$T/kids.json" 2>"$T/err" \
  || { cat "$T/err" >&2; exit 2; }
for k in $("$py" -c 'import json,sys;print(" ".join(i["key"] for i in json.load(open(sys.argv[1],encoding="utf-8"))))' "$(native "$T/kids.json")"); do
  acli jira workitem view "$k" --fields 'issuelinks' --json > "$T/link-$k.json" 2>"$T/err" || { cat "$T/err" >&2; exit 2; }
done

PYTHONIOENCODING=utf-8 "$py" - "$(native "$T")" "$N" <<'PY' | tr -d '\r'
import collections, glob, json, os, sys
T, n = sys.argv[1], sys.argv[2]
load = lambda p: json.load(open(p, encoding="utf-8"))
e = load(os.path.join(T, "epic.json"))["fields"]
if e["issuetype"]["name"] != "Epic":
    print("VUNG-%s is a %s, not an Epic: use ngvu-ticket-investigation" % (n, e["issuetype"]["name"]), file=sys.stderr)
    sys.exit(4)
kids = load(os.path.join(T, "kids.json"))
keys = {k["key"] for k in kids}
cell = lambda s: s.replace("|", "\\|")
print("# Jira inventory — VUNG-%s: %s\n" % (n, cell(e["summary"])))
print("Epic status: **%s**. Child tickets: **%d**.\n" % (e["status"]["name"], len(kids)))
cnt = collections.Counter((k["fields"]["issuetype"]["name"], k["fields"]["status"]["statusCategory"]["name"]) for k in kids)
print("| Type | Status category | Count |\n|---|---|--:|")
for (t, s), c in sorted(cnt.items()): print("| %s | %s | %d |" % (t, s, c))
print("\n| Key | Type | Status | Summary | Blocked by | Blocks | Other links |\n|---|---|---|---|---|---|---|")
for k in kids:
    f = k["fields"]; blk, blocks, other = [], [], []
    for l in load(os.path.join(T, "link-%s.json" % k["key"]))["fields"].get("issuelinks") or []:
        t = l["type"]; inward = "inwardIssue" in l
        o = (l.get("inwardIssue") or l.get("outwardIssue"))["key"]
        mark = o if o in keys else o + " (outside the epic)"
        if t["name"] == "Blocks": (blk if inward else blocks).append(mark)
        else: other.append("%s %s" % (t["inward"] if inward else t["outward"], mark))
    print("| %s | %s | %s (%s) | %s | %s | %s | %s |" % (
        k["key"], f["issuetype"]["name"], f["status"]["name"], f["status"]["statusCategory"]["name"],
        cell(f["summary"]), ", ".join(blk) or "—", ", ".join(blocks) or "—", "; ".join(other) or "—"))
PY
exit "${PIPESTATUS[0]}"
