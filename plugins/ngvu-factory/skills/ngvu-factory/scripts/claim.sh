#!/usr/bin/env bash
# Claim an epic child for this session. mkdir is atomic, so exactly one session wins.
# Usage: claim.sh <epic-factory-dir> <VUNG-key>            claim
#        claim.sh --release <epic-factory-dir> <VUNG-key>  release a claim this run made
# Exit: 0 claimed/released, 10 already claimed, 18 nothing to release, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

release=0; [ "${1:-}" = "--release" ] && { release=1; shift; }
dir="${1:-}"; key="${2:-}"
[ -n "$dir" ] && [[ "$key" =~ ^VUNG-[0-9]+$ ]] || kf_die "usage: claim.sh <epic-factory-dir> <VUNG-key>"
if [ "$release" = 1 ]; then
  [ -d "$dir/claims/$key" ] || { echo "not claimed: $key" >&2; exit 18; }
  rm -f "$dir/claims/$key/claimed-at" && rmdir "$dir/claims/$key" || kf_die "cannot release $key"
  echo "released $key"; exit 0
fi
mkdir -p "$dir/claims" || kf_die "cannot create $dir/claims"
if mkdir "$dir/claims/$key" 2>/dev/null; then
  date -u +%Y-%m-%dT%H:%M:%SZ > "$dir/claims/$key/claimed-at"
  echo "claimed $key"
  exit 0
fi
echo "already claimed: $key" >&2
exit 10
