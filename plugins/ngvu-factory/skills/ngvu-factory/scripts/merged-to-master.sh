#!/usr/bin/env bash
# Has VUNG-<n> reached origin/master? Prints "<sha> <committer date ISO> <subject>" of the newest
# evidence: a merge commit "Merge pull request #N from <...>vung-<n>-<...>" (GitHub) or "Merged in <...>vung-<n>-<...>
# (pull request #N)" (GitHub) or, failing
# that, a "VUNG-<n>: ..." commit. Searches the last 400 commits of origin/master.
# Usage: merged-to-master.sh <repo> <VUNG-n>
# Exit: 0 merged, 11 not merged, 7 fetch failed, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

repo="${1:-}"; key="${2:-}"
[[ -n "$repo" && "$key" =~ ^VUNG-([0-9]+)$ ]] || kf_die "usage: merged-to-master.sh <repo> <VUNG-n>"
n="${BASH_REMATCH[1]}"
git -C "$repo" fetch -q origin || { echo "git fetch failed in $repo" >&2; exit 7; }

fmt='%h %cI %s'
hit=$(git -C "$repo" log refs/remotes/origin/master -n 400 --merges --format="$fmt" | grep -iE " (Merged in|Merge pull request #[0-9]+ from) (.*/)?vung-$n-" | head -n1)
[ -n "$hit" ] || hit=$(git -C "$repo" log refs/remotes/origin/master -n 400 --no-merges --format="$fmt" | grep -E " VUNG-$n:" | head -n1)
[ -n "$hit" ] && { echo "$hit"; exit 0; }
echo "not merged: no VUNG-$n merge or commit in the last 400 commits of origin/master"
exit 11
