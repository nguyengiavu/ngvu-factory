#!/usr/bin/env bash
# Cost of one ticket so far, from its factory dir (read-only).
# Agent runs are counted from the files they leave behind; token totals come from FD/usage.jsonl
# (one JSON object per finished agent, written by the orchestrator; fields may be null when the
# Agent tool did not report them).
# Usage: cost-report.sh <factory dir>     Exit: 0 ok, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

fd="${1:-}"
[ -n "$fd" ] && [ -d "$fd" ] || kf_die "usage: cost-report.sh <factory dir>"

rounds=$(find "$fd" -maxdepth 1 -type d -name 'round-*' | wc -l)
reviews=$(find "$fd" -mindepth 2 -maxdepth 2 -path '*/round-*/review-*.md' | wc -l)
builds=0; [ -f "$fd/build.md" ] && builds=$(grep -c '^### Round' "$fd/build.md")
spec=0; [ -f "$fd/spec.md" ] && spec=1
approver=0; [ -f "$fd/decision.md" ] && ! grep -q '^No review rounds left' "$fd/decision.md" && approver=1
reworks=$(find "$fd" -maxdepth 1 -name 'rework-*.md' | wc -l)
feedback=$(find "$fd" -maxdepth 1 -name 'pr-feedback-*.md' | wc -l)

echo "Factory dir: $fd"
printf '%-22s %s\n' "review rounds" "$rounds" "spec-writer runs" "$spec" "builder rounds" "$builds" \
  "review runs" "$reviews" "approver runs" "$approver" "rework notes" "$reworks" "pr-feedback rounds" "$feedback" \
  "agent runs (min)" "$(( spec + builds + reviews + approver ))"

if [ -f "$fd/usage.jsonl" ]; then
  py="$(kf_python)" || exit 1
  "$py" -c '
import json, sys
rows = [json.loads(l) for l in open(sys.argv[1], encoding="utf-8-sig") if l.strip()]
def total(k):
    vals = [r.get(k) for r in rows if isinstance(r.get(k), (int, float))]
    return sum(vals), len(vals)
t, nt = total("total_tokens"); d, nd = total("duration_ms")
print("%-22s %s" % ("usage rows", len(rows)))
print("%-22s %s (from %d of %d rows)" % ("total tokens", t, nt, len(rows)))
print("%-22s %.1f min (from %d rows)" % ("agent time", d / 60000.0, nd))
by = {}
for r in rows:
    if isinstance(r.get("total_tokens"), (int, float)):
        by[r.get("agent", "?")] = by.get(r.get("agent", "?"), 0) + r["total_tokens"]
for a, v in sorted(by.items(), key=lambda x: -x[1]):
    print("  %-34s %s" % (a, v))
' "$(kf_native_path "$fd/usage.jsonl")" | tr -d '\r'
else
  echo "usage.jsonl: none (token totals unknown)"
fi
