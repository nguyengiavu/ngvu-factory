#!/usr/bin/env bash
# Check that a branch name can be created locally and later pushed.
# Usage: ref-check.sh <repo> <branch>     (run git fetch first; this script does not)
# Exit: 0 free, 5 exists (local or origin), 6 ref conflict (git cannot hold both a/b and a/b/c), 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

repo="${1:-}"; br="${2:-}"
[ -n "$repo" ] && [ -n "$br" ] || kf_die "usage: ref-check.sh <repo> <branch>"

exists() {
  git -C "$repo" show-ref --verify -q "refs/heads/$1" || git -C "$repo" show-ref --verify -q "refs/remotes/origin/$1"
}

if exists "$br"; then echo "branch already exists: $br"; exit 5; fi

p="$br"
while [[ "$p" == */* ]]; do
  p="${p%/*}"
  if exists "$p"; then echo "ref conflict: branch '$p' exists, so '$br' cannot be created"; exit 6; fi
done

if [ -n "$(git -C "$repo" for-each-ref --format='%(refname)' "refs/heads/$br/" "refs/remotes/origin/$br/")" ]; then
  echo "ref conflict: branches exist under '$br/'"; exit 6
fi
exit 0
