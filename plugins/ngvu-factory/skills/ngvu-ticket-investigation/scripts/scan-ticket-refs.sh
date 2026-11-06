#!/usr/bin/env bash
# scan-ticket-refs.sh — find every trace of a VUNG ticket across the whole ngvu workspace.
#
# Why: a ticket's code is rarely in one repo, and is often on a branch NOT yet merged
# to master (the epic branch). Read only master and you wrongly conclude "nobody did anything".
#
#   ./scan-ticket-refs.sh 100009            # scan local git log + remote heads
#   ./scan-ticket-refs.sh 100009 --local    # local only (fast, no network)
#   ./scan-ticket-refs.sh 100009 --repos "example_core example_payment"
#
# Output: table repo -> matching commit / branch, with suggested commands for details.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"
NUM=""
MODE="full"
REPO_FILTER=""

while [ $# -gt 0 ]; do
  case "$1" in
    --local)  MODE="local"; shift ;;
    --repos)  REPO_FILTER="$2"; shift 2 ;;
    --root)   ROOT="$2"; TASKS="$ROOT/tasks"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *)        NUM="${1#VUNG-}"; NUM="${NUM#vung-}"; shift ;;
  esac
done

[ -z "$NUM" ] && { echo "Missing ticket number. Example: $0 100009" >&2; exit 1; }
KEY="VUNG-$NUM"

echo "== Scanning $KEY in $ROOT (mode: $MODE) =="
echo

repos() {
  for d in "$ROOT"/services/*/ "$ROOT"/nextjs/*/ "$ROOT"/infra/*/; do
    [ -d "$d/.git" ] || continue
    if [ -n "$REPO_FILTER" ]; then
      name=$(basename "$d")
      echo "$REPO_FILTER" | tr ' ' '\n' | grep -qx "$name" || continue
    fi
    echo "$d"
  done
}

FOUND=0

echo "--- 1. Commits in local refs (every fetched branch) ---"
while read -r d; do
  [ -z "$d" ] && continue
  out=$(cd "$d" && git log --all --oneline -i --grep="$NUM" 2>/dev/null | head -12)
  if [ -n "$out" ]; then
    FOUND=1
    echo
    echo "### $(basename "$d")"
    echo "$out" | sed 's/^/    /'
  fi
done < <(repos)
[ "$FOUND" = 0 ] && echo "    (no commits — maybe not fetched yet, see section 2)"

if [ "$MODE" = "full" ]; then
  echo
  echo "--- 2. Remote branches (needs network; ~5-40s per repo) ---"
  while read -r d; do
    [ -z "$d" ] && continue
    out=$(cd "$d" && timeout 45 git ls-remote --heads origin 2>/dev/null | grep -i "$NUM")
    if [ -n "$out" ]; then
      echo
      echo "### $(basename "$d")"
      echo "$out" | sed 's|^|    |'
      echo "    → fetch: cd $d && git fetch origin '<branch>:refs/remotes/origin/<branch>'"
    fi
  done < <(repos)
fi

echo
echo "--- 3. Ticket mentioned in files (docs, config, comments) ---"
grep -rl "$NUM" "$TASKS" "$ROOT/docs" 2>/dev/null | head -10 | sed 's/^/    /'

echo
echo "== Suggested next steps =="
echo "  Diff of a branch:      ./branch-status.sh <repo-path> <branch>"
echo "  One commit:            cd <repo> && git show <sha> --stat"
echo "  If sections 1 and 2 are both empty: this ticket may be the first story to touch that code,"
echo "  or the code is on the parent EPIC branch — scan again with the epic number."
