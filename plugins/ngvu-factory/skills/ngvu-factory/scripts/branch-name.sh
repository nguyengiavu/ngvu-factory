#!/usr/bin/env bash
# Build a branch name following the team convention.
# Usage: branch-name.sh ticket <n> <slug>
#        branch-name.sh epic   <epic> <slug>
#        branch-name.sh child  <epic> <n> <slug>
set -uo pipefail
source "$(dirname "$0")/lib.sh"

usage() { kf_die "usage: branch-name.sh ticket <n> <slug> | epic <epic> <slug> | child <epic> <n> <slug>"; }
num()  { [[ "${1:-}" =~ ^[0-9]+$ ]]; }
slug() { [[ "${1:-}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; }

prefix="$(kf_cfg branchPrefix)" || exit 1
case "${1:-}" in
  ticket) num "${2:-}" && slug "${3:-}" || usage; echo "${prefix}vung-$2-$3" ;;
  epic)   num "${2:-}" && slug "${3:-}" || usage; echo "${prefix}vung-$2/EPIC-$3" ;;
  child)  num "${2:-}" && num "${3:-}" && slug "${4:-}" || usage; echo "${prefix}vung-$2/vung-$3-$4" ;;
  *) usage ;;
esac
