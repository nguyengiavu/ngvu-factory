#!/usr/bin/env bash
# Read-only health snapshot of one namespace: pods, deployments, recent Warning events.
# Usage: ENV=dev KUBE_CONTEXT=<ctx> [SERVICES="a b"] pod_health.sh     KF_DRY_RUN=1 prints the commands.
# Exit: 0 ok, 1 usage/refused.
set -uo pipefail
die() { echo "pod_health: $*" >&2; exit 1; }

env="${ENV:-}"; ctx="${KUBE_CONTEXT:-}"; services="${SERVICES:-}"
[[ "$env" =~ ^[a-z0-9-]+$ ]] || die "ENV must be a lower-case namespace, e.g. dev"
[[ "$ctx" =~ ^[A-Za-z0-9._:/@-]+$ ]] || die "KUBE_CONTEXT is required (name the cluster explicitly)"
for s in $services; do [[ "$s" =~ ^[a-z0-9-]+$ ]] || die "bad service name '$s'"; done
[ "$env" != prod ] || [ "${CONFIRM_PROD:-}" = 1 ] || die "prod needs the user's explicit yes and CONFIRM_PROD=1"

k=(kubectl --context "$ctx" -n "$env")
pods=("${k[@]}" get pods --no-headers -o 'custom-columns=NAME:.metadata.name,PHASE:.status.phase,READY:.status.containerStatuses[*].ready,RESTARTS:.status.containerStatuses[*].restartCount,REASON:.status.containerStatuses[*].state.waiting.reason,STARTED:.status.startTime')
deps=("${k[@]}" get deployments --no-headers -o 'custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas,READY:.status.readyReplicas,UPDATED:.status.updatedReplicas,AVAILABLE:.status.availableReplicas')
evts=("${k[@]}" get events --field-selector type=Warning --sort-by=.lastTimestamp --no-headers -o 'custom-columns=LAST:.lastTimestamp,OBJECT:.involvedObject.name,REASON:.reason,MESSAGE:.message')
if [ "${KF_DRY_RUN:-}" = 1 ]; then
  for a in pods deps evts; do declare -n c=$a; printf '%q ' "${c[@]}"; echo; done
  exit 0
fi
command -v kubectl >/dev/null || die "kubectl not found"

re=""; [ -z "$services" ] || re="^($(echo $services | tr ' ' '|'))"
keep() { if [ -z "$re" ]; then cat; else grep -E "$re" || true; fi; }
echo "== pods ($ctx / $env): NAME PHASE READY RESTARTS WAITING-REASON STARTED"; "${pods[@]}" | keep
echo "== deployments: NAME DESIRED READY UPDATED AVAILABLE";                    "${deps[@]}" | keep
echo "== recent Warning events (last 15)"
"${evts[@]}" | { if [ -z "$re" ]; then cat; else grep -E "$(echo $services | tr ' ' '|')" || true; fi; } | tail -n 15
