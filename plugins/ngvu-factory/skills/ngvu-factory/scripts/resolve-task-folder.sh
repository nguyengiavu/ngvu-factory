#!/usr/bin/env bash
# Find the investigation folder(s) of a Jira key under the tasks dir.
# Usage: resolve-task-folder.sh <number> [tasks-dir]
# Matches VUNG-<n>, VUNG-<n>-<slug>, EPIC-VUNG-<n>, EPIC-VUNG-<n>-<slug>.
# Prints "<folder>\t<slug>" per match (slug empty when the folder has none).
# Exit: 0 one match, 3 none, 4 several (all printed), 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

n="${1:-}"
[[ "$n" =~ ^[0-9]+$ ]] || kf_die "usage: resolve-task-folder.sh <number> [tasks-dir]"
tasks="${2:-}"
[ -n "$tasks" ] || tasks="$(kf_cfg paths.tasks)" || exit 1
[ -d "$tasks" ] || kf_die "tasks dir not found: $tasks"

count=0
for p in "$tasks/VUNG-$n" "$tasks/VUNG-$n-"* "$tasks/EPIC-VUNG-$n" "$tasks/EPIC-VUNG-$n-"*; do
  [ -d "$p" ] || continue
  name="$(basename "$p")"
  case "$name" in
    "VUNG-$n-"*)      slug="${name#"VUNG-$n-"}" ;;
    "EPIC-VUNG-$n-"*) slug="${name#"EPIC-VUNG-$n-"}" ;;
    *)               slug="" ;;
  esac
  printf '%s\t%s\n' "$name" "$slug"
  count=$((count+1))
done

[ "$count" -eq 1 ] && exit 0
[ "$count" -eq 0 ] && exit 3
exit 4
