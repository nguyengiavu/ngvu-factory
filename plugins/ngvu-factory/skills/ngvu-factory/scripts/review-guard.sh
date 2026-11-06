#!/usr/bin/env bash
# Prove a review round changed no code: reviewers never edit, commit or leave files behind.
# Usage: review-guard.sh snapshot <round-dir> <worktree>...   record each worktree's HEAD
#        review-guard.sh verify <round-dir>                    HEAD unchanged and tree clean
# Exit: 0 ok, 19 a worktree changed (prints what), 2 no snapshot, 1 usage or not a git worktree.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

mode="${1:-}"; dir="${2:-}"
[ -n "$dir" ] || kf_die "usage: review-guard.sh snapshot <round-dir> <worktree>... | verify <round-dir>"
heads="$dir/heads.txt"
case "$mode" in
  snapshot)
    shift 2
    [ $# -gt 0 ] || kf_die "snapshot needs at least one worktree"
    out=""
    for wt in "$@"; do
      sha=$(git -C "$wt" rev-parse HEAD 2>/dev/null) || kf_die "not a git worktree: $wt"
      out+="$wt"$'\t'"$sha"$'\n'
    done
    mkdir -p "$dir" && printf '%s' "$out" > "$heads" || kf_die "cannot write $heads"
    ;;
  verify)
    [ -f "$heads" ] || { echo "no snapshot: $heads" >&2; exit 2; }
    rc=0
    while IFS=$'\t' read -r wt sha; do
      [ -n "$wt" ] || continue
      now=$(git -C "$wt" rev-parse HEAD 2>/dev/null) || kf_die "not a git worktree: $wt"
      [ "$now" = "$sha" ] || { echo "$wt: HEAD moved $sha -> $now during review"; rc=19; }
      dirty=$(git -C "$wt" status --porcelain) || kf_die "git status failed in $wt"
      [ -z "$dirty" ] || { echo "$wt: uncommitted changes during review:"; echo "$dirty"; rc=19; }
    done < "$heads"
    exit $rc
    ;;
  *) kf_die "usage: review-guard.sh snapshot <round-dir> <worktree>... | verify <round-dir>" ;;
esac
