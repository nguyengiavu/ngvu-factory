#!/usr/bin/env bash
# Run a plugin's eval suite with this factory's safe defaults:
#   --no-publish      reports stay local (data-protection: nothing goes to claude.ai)
#   --runs 1          one run per case unless RUNS is set
#   --ablation none   no no-plugin baseline arm unless ABLATION=with-without (doubles the cost)
#   --max-cost-usd    hard ceiling, default 3 (MAX_USD)
# Every case spawns real agents on your account: say yes to the cost before running.
# Usage: run-evals.sh <plugin> [--case <glob>] [extra claude plugin eval flags...]
#   e.g. run-evals.sh ngvu-factory --case sec-clean-change
# Exit: claude plugin eval's own (1 below threshold, 2 cost ceiling hit).
set -uo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plugin="${1:-}"; shift || true
[ -n "$plugin" ] && [ -d "$repo/plugins/$plugin/evals" ] || {
  echo "usage: run-evals.sh <plugin> [flags]; plugins with evals:" >&2
  ls -d "$repo"/plugins/*/evals 2>/dev/null | sed -E 's#.*/plugins/([^/]+)/evals#  \1#' >&2
  exit 1
}
exec claude plugin eval "$repo/plugins/$plugin" \
  --no-publish \
  --runs "${RUNS:-1}" \
  --ablation "${ABLATION:-none}" \
  --max-cost-usd "${MAX_USD:-3}" \
  --allow-tools Agent \
  "$@"
