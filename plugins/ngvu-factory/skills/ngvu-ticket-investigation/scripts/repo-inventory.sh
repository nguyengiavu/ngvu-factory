#!/usr/bin/env bash
# repo-inventory.sh — quick snapshot of the ngvu repos related to a topic.
#
# Why: the workspace has ~90 repos. Before reading code, know which repos exist
# locally, which branch each is on, and its last commit. If the working tree is dirty
# or the branch is someone else's feature branch, every "the current code is X" is wrong.
#
#   ./repo-inventory.sh                    # every repo with .git
#   ./repo-inventory.sh payment store      # only repos whose name contains 'payment' or 'store'
#   ./repo-inventory.sh --dirty            # only repos with uncommitted changes

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"
DIRTY_ONLY=0
FILTERS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --dirty) DIRTY_ONLY=1; shift ;;
    --root)  ROOT="$2"; TASKS="$ROOT/tasks"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) FILTERS+=("$1"); shift ;;
  esac
done

printf "%-34s %-46s %-10s %s\n" "REPO" "BRANCH" "STATE" "LAST COMMIT"
printf "%-34s %-46s %-10s %s\n" "----" "------" "-----" "-----------"

for d in "$ROOT"/services/*/ "$ROOT"/nextjs/*/ "$ROOT"/infra/*/; do
  [ -d "$d/.git" ] || continue
  name=$(basename "$d")

  if [ ${#FILTERS[@]} -gt 0 ]; then
    match=0
    for f in "${FILTERS[@]}"; do
      case "$name" in *"$f"*) match=1 ;; esac
    done
    [ "$match" = 1 ] || continue
  fi

  branch=$(cd "$d" && git branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch="(detached)"
  changes=$(cd "$d" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$changes" -gt 0 ]; then state="DIRTY($changes)"; else state="clean"; fi
  [ "$DIRTY_ONLY" = 1 ] && [ "$changes" = 0 ] && continue
  last=$(cd "$d" && git log -1 --format='%h %s' 2>/dev/null | cut -c1-58)

  printf "%-34s %-46s %-10s %s\n" "$name" "${branch:0:45}" "$state" "$last"
done

echo
echo "Note: a branch that is NOT master/main means you are reading feature-branch code."
echo "Before concluding 'the current code is X', check with: ./branch-status.sh <repo> <branch>"
