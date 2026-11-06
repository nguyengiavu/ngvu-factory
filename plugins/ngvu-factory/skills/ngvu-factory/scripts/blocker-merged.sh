#!/usr/bin/env bash
# Is a blocking epic child merged into the epic branch on origin?
# Usage: blocker-merged.sh <repo> <epic-branch> <child-branch | VUNG-n>
# "Merged" needs evidence of the child's own work in origin/<epic> beyond origin/master:
#   a commit titled "VUNG-<n>: ..." (builder convention), or a merge commit
#   "Merge pull request #N from <...>vung-<n>-<...>" (GitHub) or "Merged in <...>vung-<n>-<...> (pull request #N)"
#   (GitHub), which also covers deleted source branches. A GitHub squash merge leaves no merge commit:
#   its PR title must start "VUNG-<n>:". A branch that merely points at the epic tip is NOT merged.
# Exit: 0 merged, 11 not merged, 23 merged to master after the epic branched (not in the epic),
#       12 epic branch not on origin, 7 fetch failed, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

repo="${1:-}"; epic="${2:-}"; child="${3:-}"
[ -n "$child" ] || kf_die "usage: blocker-merged.sh <repo> <epic-branch> <child-branch | VUNG-n>"
if [[ "$child" =~ ^VUNG-([0-9]+)$ ]]; then
  n="${BASH_REMATCH[1]}"
elif [[ "${child,,}" =~ (^|/)vung-([0-9]+)-[^/]*$ ]]; then
  n="${BASH_REMATCH[2]}"
else
  kf_die "cannot read a VUNG key from '$child'"
fi

MERGE_RE="^(Merged in|Merge pull request #[0-9]+ from) (.*/)?vung-$n-"
git -C "$repo" fetch -q origin || { echo "git fetch failed in $repo" >&2; exit 7; }
epic_ref="refs/remotes/origin/$epic"
git -C "$repo" rev-parse -q --verify "$epic_ref" >/dev/null || { echo "epic branch not on origin: $epic"; exit 12; }

# Only history that the epic adds on top of master counts.
range="$epic_ref"
git -C "$repo" rev-parse -q --verify refs/remotes/origin/master >/dev/null && range="refs/remotes/origin/master..$epic_ref"

if git -C "$repo" log "$range" --no-merges --format=%s | grep -qE "^VUNG-$n:"; then
  echo "merged (VUNG-$n commits in $epic)"; exit 0
fi
if git -C "$repo" log "$range" --merges --format=%s | grep -qiE "$MERGE_RE"; then
  echo "merged (merge commit for VUNG-$n in $epic)"; exit 0
fi
# Merged straight to master after the epic branched (VUNG-100008, 2026-10): done, but the epic branch
# lacks the code, so the caller must not base a dependent child on origin/<epic> as is.
if git -C "$repo" rev-parse -q --verify refs/remotes/origin/master >/dev/null; then
  late="$epic_ref..refs/remotes/origin/master"
  if git -C "$repo" log "$late" --no-merges --format=%s | grep -qE "^VUNG-$n:" \
     || git -C "$repo" log "$late" --merges --format=%s | grep -qiE "$MERGE_RE"; then
    echo "merged to master, not in $epic: VUNG-$n"; exit 23
  fi
fi
echo "not merged: VUNG-$n has no merged work in $epic"
exit 11
