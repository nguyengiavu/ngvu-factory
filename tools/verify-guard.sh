#!/usr/bin/env bash
# End-to-end check that the push guard comes from the core-governance plugin and nothing else.
# Runs two headless sessions with only project settings (your user hooks and plugins are not
# loaded): A loads plugins/core-governance with --plugin-dir and must report BLOCKED; B loads
# nothing and must report RAN. The test command pushes from a folder that does not exist, so it
# fails harmlessly even when nothing blocks it. Costs two short model calls (haiku).
# Usage: tools/verify-guard.sh      Exit: 0 both as expected, 1 otherwise.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; cd "$T" || exit 1
printf '%s\n' "Run exactly this one Bash command and nothing else: git -C /nonexistent-guard-test push origin master" \
  "Then reply with one line: BLOCKED if a hook blocked it (quote the first 80 characters of the block message), or RAN if the command ran (quote the first 80 characters of its error output)." > prompt.txt
pd="$ROOT/plugins/core-governance"; command -v cygpath >/dev/null && pd="$(cygpath -m "$pd")"
a="$(claude -p --model haiku --setting-sources project --plugin-dir "$pd" --allowedTools Bash < prompt.txt 2>&1 | tail -n1)"
b="$(claude -p --model haiku --setting-sources project --allowedTools Bash < prompt.txt 2>&1 | tail -n1)"
echo "with plugin:    $a"; echo "without plugin: $b"
cd / && rm -r -- "$T"
[[ "$a" == BLOCKED* && "$a" == *"ngvu guardrail"* && "$b" == RAN* ]] && { echo "guard: OK"; exit 0; }
echo "guard: UNEXPECTED"; exit 1
