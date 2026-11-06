#!/usr/bin/env bash
# Run the unit-test gate for one worktree, chosen by repo kind (config unitTest.<kind>).
# java-service falls back to paths.unitTestScript (legacy key). A command ending in .bat runs through cmd,
# anything else through bash in the worktree; "{base}" is replaced by <base-ref>.
# nextjs needs node_modules in the worktree (npm ci needs registry credentials, so a human runs it).
# KF_DRY_RUN=1 prints the command instead of running it.
# Usage: unit-test.sh <worktree> [<kind> [<base-ref>]]     kind defaults to java-service.
# Exit: the command's own exit code; 20 dependencies not installed; 1 usage or config error.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

wt="${1:-}"; kind="${2:-java-service}"; base="${3:-}"
[ -n "$wt" ] && [ -d "$wt" ] || kf_die "usage: unit-test.sh <worktree> [<kind> [<base-ref>]] (the worktree must exist)"
[[ "$kind" =~ ^(java-service|nextjs)$ ]] || kf_die "unknown kind '$kind' (java-service|nextjs)"

cmdline="$(kf_cfg "unitTest.$kind" 2>/dev/null)"
if [ -z "$cmdline" ] && [ "$kind" = java-service ]; then cmdline="$(kf_cfg paths.unitTestScript)" || exit 1; fi
[ -n "$cmdline" ] || kf_die "unitTest.$kind is not set"
if [[ "$cmdline" == *"{base}"* ]]; then
  [ -n "$base" ] || kf_die "kind $kind needs <base-ref>"
  cmdline="${cmdline//\{base\}/$base}"
fi

if [ "$kind" = nextjs ] && [ ! -d "$wt/node_modules" ]; then
  echo "ngvu-factory: no node_modules in $wt; a human must run 'npm ci' there (needs Artifact Registry auth)" >&2
  exit 20
fi

if [ "${KF_DRY_RUN:-}" = 1 ]; then echo "[$kind] cd $wt && $cmdline"; exit 0; fi
cd "$wt" || kf_die "cannot enter $wt"
if [[ "$cmdline" == *.bat ]]; then
  cmd //c "$(kf_native_path "$cmdline" | tr '/' '\')"
else
  bash -c "$cmdline"
fi
