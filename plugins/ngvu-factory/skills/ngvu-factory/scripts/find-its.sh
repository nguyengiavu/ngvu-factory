#!/usr/bin/env bash
# List integration tests (*IT.java) that reference classes changed since <base-ref>.
# Changed = committed since the merge-base, plus uncommitted and untracked files, so it works
# whether or not the builder has committed yet.
# Usage: find-its.sh <worktree> <base-ref>
# Exit: 0 ok (empty output means none), 1 usage, bad base ref or not a git worktree.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

wt="${1:-}"; base="${2:-}"
[ -n "$base" ] || kf_die "usage: find-its.sh <worktree> <base-ref>"
cd "$wt" || kf_die "no such worktree: $wt"
mb=$(git merge-base "$base" HEAD 2>/dev/null) || kf_die "cannot resolve base '$base' in $wt"
tracked=$(git diff --name-only "$mb") || kf_die "git diff failed in $wt"
untracked=$(git ls-files --others --exclude-standard) || kf_die "git ls-files failed in $wt"

classes=$(printf '%s\n%s\n' "$tracked" "$untracked" | grep -E '(^|/)src/main/java/.+\.java$' | sed -E 's#.*/##; s#\.java$##' | sort -u)
[ -n "$classes" ] || exit 0
its=$({ git ls-files; printf '%s\n' "$untracked"; } | grep -E 'IT\.java$' | sort -u)
[ -n "$its" ] || exit 0
{
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    while IFS= read -r f; do
      [ -f "$f" ] && grep -qw -- "$c" "$f" 2>/dev/null && echo "$f"
    done <<< "$its"
  done <<< "$classes"
} | sort -u
exit 0
