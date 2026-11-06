#!/usr/bin/env bash
# Count ERROR+ log entries of one container in one bounded window (read-only Cloud Logging query).
# Project comes from config verify.logProject.<env> (else .default); prod has no default on purpose.
# The window may not exceed config verify.maxWindowHours. Prints "<count>" or "<limit>+" when capped.
# KF_DRY_RUN=1 prints the gcloud command instead of running it.
# Usage: error-count.sh <env> <container> <from-UTC-ISO> <to-UTC-ISO>
# Exit: 0 ok, 21 window too long or unparsable, 22 no log project for env, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

env="${1:-}"; container="${2:-}"; from="${3:-}"; to="${4:-}"
[ -n "$to" ] || kf_die "usage: error-count.sh <env> <container> <from-UTC-ISO> <to-UTC-ISO>"
[[ "$container" =~ ^[a-z0-9-]+$ && "$env" =~ ^[a-z0-9-]+$ ]] || kf_die "env/container must be lower-case names"

project="$(kf_cfg "verify.logProject.$env" 2>/dev/null)"
[ -n "$project" ] || [ "$env" = prod ] || project="$(kf_cfg verify.logProject.default 2>/dev/null)"
[ -n "$project" ] || { echo "no log project configured for env '$env' (config verify.logProject)" >&2; exit 22; }
max_h="$(kf_cfg verify.maxWindowHours 2>/dev/null)"; max_h="${max_h:-6}"
limit=2000

f=$(date -u -d "$from" +%s 2>/dev/null) && t=$(date -u -d "$to" +%s 2>/dev/null) || { echo "cannot parse window" >&2; exit 21; }
[ "$t" -gt "$f" ] && [ $(( t - f )) -le $(( max_h * 3600 )) ] || { echo "window must be >0 and <= ${max_h}h" >&2; exit 21; }

filter="resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"$env\" AND resource.labels.container_name=\"$container\" AND severity>=ERROR AND timestamp>=\"$from\" AND timestamp<\"$to\""
if [ "${KF_DRY_RUN:-}" = 1 ]; then
  echo "gcloud logging read '$filter' --project=$project --limit=$limit --format=value(timestamp)"; exit 0
fi
count=$(gcloud logging read "$filter" --project="$project" --limit="$limit" --format='value(timestamp)' | grep -c .)
[ "$count" -ge "$limit" ] && echo "${limit}+" || echo "$count"
