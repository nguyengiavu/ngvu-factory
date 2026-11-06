#!/usr/bin/env bash
# Read-only, bounded Cloud Logging read across several containers, merged by time.
# Usage: ENV=dev SERVICES="web docs" [SEVERITY=WARNING] [SEARCH=text] [WINDOW_HOURS=1 | FROM=.. TO=..] [LIMIT=200] trace_flow_logs.sh
# KF_DRY_RUN=1 prints the gcloud command. Exit: 0 ok, 1 usage/refused.
set -uo pipefail
die() { echo "trace_flow_logs: $*" >&2; exit 1; }

env="${ENV:-}"; services="${SERVICES:-}"; sev="${SEVERITY:-WARNING}"; search="${SEARCH:-}"
hours="${WINDOW_HOURS:-1}"; limit="${LIMIT:-200}"; from="${FROM:-}"; to="${TO:-}"
[[ "$env" =~ ^[a-z0-9-]+$ ]] || die "ENV must be a lower-case name, e.g. dev"
[ -n "$services" ] || die "SERVICES is required (space-separated container names)"
for s in $services; do [[ "$s" =~ ^[a-z0-9-]+$ ]] || die "bad service name '$s' (lower-case letters, digits, '-')"; done
[[ "$sev" =~ ^(DEFAULT|DEBUG|INFO|NOTICE|WARNING|ERROR|CRITICAL|ALERT|EMERGENCY)$ ]] || die "bad SEVERITY '$sev'"
[[ "$limit" =~ ^[0-9]+$ && "$limit" -ge 1 && "$limit" -le 5000 ]] || die "LIMIT must be 1..5000"
[ "$env" != prod ] || [ "${CONFIRM_PROD:-}" = 1 ] || die "prod needs the user's explicit yes and CONFIRM_PROD=1"
case "$search" in *[$'\n\r']*) die "SEARCH must be one line";; esac

if [ -n "$from" ] && [ -n "$to" ]; then
  f=$(date -u -d "$from" +%s 2>/dev/null) && t=$(date -u -d "$to" +%s 2>/dev/null) || die "cannot parse FROM/TO"
  [ "$t" -gt "$f" ] || die "TO must be after FROM"
  [ $(( t - f )) -le $(( 744 * 3600 )) ] || die "window over 31 days: aggregate instead, or ask the user"
else
  [[ "$hours" =~ ^[0-9]+$ && "$hours" -ge 1 && "$hours" -le 744 ]] || die "WINDOW_HOURS must be 1..744"
  from=$(date -u -d "$hours hours ago" +%Y-%m-%dT%H:%M:%SZ); to=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi

names=""; for s in $services; do names+="${names:+ OR }resource.labels.container_name=\"$s\""; done
filter="resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"$env\" AND ($names) AND severity>=$sev AND timestamp>=\"$from\" AND timestamp<\"$to\""
if [ -n "$search" ]; then esc=${search//\\/\\\\}; esc=${esc//\"/\\\"}; filter+=" AND SEARCH(\"$esc\")"; fi

args=(logging read "$filter" --order=asc --limit="$limit" --format='value(timestamp,resource.labels.container_name,severity,textPayload,jsonPayload.message)')
[ -z "${PROJECT:-}" ] || args+=(--project="$PROJECT")
if [ "${KF_DRY_RUN:-}" = 1 ]; then printf 'gcloud'; printf ' %q' "${args[@]}"; echo; exit 0; fi
command -v gcloud >/dev/null || die "gcloud not found"
gcloud "${args[@]}" | sed -E 's/Bearer [A-Za-z0-9._~+\/=-]+/Bearer ***/g; s/eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*/JWT***/g'
