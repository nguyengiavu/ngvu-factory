#!/usr/bin/env bash
# Validate ticket.json / epic.json against the state contract (docs/ARCHITECTURE.md).
# Usage: state-check.sh <ticket|epic> <file>     Exit: 0 valid, 2 invalid, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

kind="${1:-}"; f="${2:-}"
[[ "$kind" =~ ^(ticket|epic)$ ]] && [ -n "$f" ] || kf_die "usage: state-check.sh <ticket|epic> <file>"
[ -f "$f" ] || { echo "missing: $f" >&2; exit 2; }
py="$(kf_python)" || exit 1
"$py" -c '
import json, re, sys
kind, path = sys.argv[1], sys.argv[2]
def bad(msg):
    print("invalid " + kind + ": " + msg, file=sys.stderr); sys.exit(2)
try:
    d = json.load(open(path, encoding="utf-8-sig"))
except Exception as e:
    bad("not JSON (%s)" % e)
KEY = re.compile(r"^VUNG-[0-9]+$")
STORY = re.compile(r"^S[0-9]+$")
def need(obj, k, t, where):
    if k not in obj or not isinstance(obj[k], t):
        bad("%s.%s missing or wrong type" % (where, k))
    return obj[k]
if not KEY.match(str(d.get("key", ""))): bad("key must look like VUNG-<n>")
for k in ("summary", "folder", "slug", "updatedAt"): need(d, k, str, kind)
need(d, "intakeApproved", bool, kind)
if kind == "ticket":
    if d.get("epic") is not None and not KEY.match(str(d["epic"])): bad("epic must be null or VUNG-<n>")
    for r in need(d, "repos", list, kind):
        for k in ("repo", "owner", "worktree", "branch", "base"): need(r, k, str, "repos[]")
        if r.get("kind", "java-service") not in ("java-service", "nextjs"): bad("repos[].kind must be java-service|nextjs")
    if need(d, "stage", str, kind) not in ("intake", "spec", "build", "review", "approve", "needs-human", "ready-for-pr", "verified", "closed"):
        bad("unknown stage " + d["stage"])
    if d["stage"] == "closed" and not (isinstance(d.get("closedReason"), str) and d["closedReason"].strip()):
        bad("closedReason is required when stage is closed")
    need(d, "round", int, kind); need(d, "resumesLeft", int, kind)
    rv = need(d, "reviews", dict, kind)
    for k in ("securityTenancy", "codeConventions", "contractIntegration", "dataPersistence"):
        if rv.get(k) not in ("pending", "PASS", "CHANGES"): bad("reviews.%s must be pending|PASS|CHANGES" % k)
    if rv.get("frontendUi", "n/a") not in ("n/a", "pending", "PASS", "CHANGES"): bad("reviews.frontendUi must be n/a|pending|PASS|CHANGES")
    if d.get("builderAgentId") is not None and not isinstance(d["builderAgentId"], str): bad("builderAgentId must be a string or null")
    oq = d.get("openQuestionsAccepted")
    if oq is not None and not (isinstance(oq, list) and all(isinstance(x, str) and x for x in oq)):
        bad("openQuestionsAccepted must be a list of question ids")
    pl = d.get("prLinks")
    if pl is not None and not (isinstance(pl, dict) and all(isinstance(v, str) for v in pl.values())):
        bad("prLinks must map repo names to links")
    if d.get("epicFolder") is not None and not isinstance(d["epicFolder"], str): bad("epicFolder must be a string or null")
    if d.get("story") is not None and not STORY.match(str(d["story"])): bad("story must be S<n> or null")
else:
    need(d, "repos", list, kind); need(d, "epicBranch", str, kind)
    for c in need(d, "children", list, kind):
        if not KEY.match(str(c.get("key", ""))): bad("children[].key")
        need(c, "summary", str, "children[]")
        if c.get("folder") is not None and not isinstance(c["folder"], str): bad("children[].folder")
        for k in ("blockedBy", "externalBlockers"):
            if not all(KEY.match(str(x)) for x in need(c, k, list, "children[]")): bad("children[].%s" % k)
        if c.get("state") not in ("queued", "needs-investigation"): bad("children[].state")
        if c.get("story") is not None and not STORY.match(str(c["story"])): bad("children[].story must be S<n> or null")
' "$kind" "$(kf_native_path "$f")"
