#!/usr/bin/env bash
# Create a ticket branch in its own worktree. Never reuses or overwrites anything.
# Usage: worktree-setup.sh <repo> <branch> <base-ref> <worktree-path>
# Exit: 0 ok (prints path), 7 fetch failed, 8 base ref missing, 9 worktree path exists, 5/6 from ref-check, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

repo="${1:-}"; br="${2:-}"; base="${3:-}"; wt="${4:-}"
[ -n "$wt" ] || kf_die "usage: worktree-setup.sh <repo> <branch> <base-ref> <worktree-path>"
git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || kf_die "not a git repo: $repo"

git -C "$repo" fetch -q origin || { echo "git fetch failed in $repo" >&2; exit 7; }
git -C "$repo" rev-parse --verify -q "$base^{commit}" >/dev/null || { echo "base ref not found: $base" >&2; exit 8; }
[ -e "$wt" ] && { echo "worktree path already exists: $wt" >&2; exit 9; }
bash "$KF_SCRIPTS_DIR/ref-check.sh" "$repo" "$br" || exit $?

mkdir -p "$(dirname "$wt")"
git -C "$repo" worktree add -q --no-track -b "$br" "$wt" "$base" || kf_die "git worktree add failed"
echo "$wt"
