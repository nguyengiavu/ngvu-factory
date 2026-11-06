#!/usr/bin/env bash
# Create a local branch (no worktree, no upstream). Used for epic branches.
# Usage: create-branch.sh <repo> <branch> <base-ref>
# Exit: 0 ok, 7 fetch failed, 8 base ref missing, 5/6 from ref-check, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

repo="${1:-}"; br="${2:-}"; base="${3:-}"
[ -n "$base" ] || kf_die "usage: create-branch.sh <repo> <branch> <base-ref>"
git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || kf_die "not a git repo: $repo"

git -C "$repo" fetch -q origin || { echo "git fetch failed in $repo" >&2; exit 7; }
git -C "$repo" rev-parse --verify -q "$base^{commit}" >/dev/null || { echo "base ref not found: $base" >&2; exit 8; }
bash "$KF_SCRIPTS_DIR/ref-check.sh" "$repo" "$br" || exit $?
git -C "$repo" branch --no-track "$br" "$base" || kf_die "git branch failed"
echo "$br"
