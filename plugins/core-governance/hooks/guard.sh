#!/usr/bin/env bash
# PreToolUse guard for the ngvu factory.
# Bash/PowerShell: a command matching blocked-commands.tsv is refused (exit 2, reason on stderr).
# Edit/Write/MultiEdit/NotebookEdit: a path matching protected-paths.tsv asks the human first.
# Works on the raw hook JSON with bash builtins only (no python, jq or grep): it runs before every
# tool call, and process spawns are slow on Windows.
# Known trade-off: text that merely mentions a blocked command at a segment start (e.g. a heredoc
# line "git push ...") is blocked too; the guard prefers a false block over a missed one.
set -uo pipefail
shopt -s nocasematch
dir="${BASH_SOURCE[0]%/*}"
IFS= read -r -d '' input || true

tool=""
[[ $input =~ \"tool_name\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] && tool="${BASH_REMATCH[1]}"

case "$tool" in
  Bash|PowerShell)
    while IFS=$'\t' read -r re reason unless || [ -n "$re" ]; do
      re="${re%$'\r'}"; reason="${reason%$'\r'}"; unless="${unless%$'\r'}"
      [[ -z "$re" || "$re" == \#* ]] && continue
      if [[ $input =~ $re ]]; then
        [[ -n "$unless" && $input =~ $unless ]] && continue
        echo "ngvu guard: blocked - $reason. Prepare the command for a human instead (see rules/approval-policy.md)." >&2
        exit 2
      fi
    done < "$dir/blocked-commands.tsv"
    ;;
  Edit|Write|MultiEdit|NotebookEdit)
    while IFS=$'\t' read -r re reason || [ -n "$re" ]; do
      re="${re%$'\r'}"; reason="${reason%$'\r'}"
      [[ -z "$re" || "$re" == \#* ]] && continue
      if [[ $input =~ $re ]]; then
        printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"ngvu guard: %s"}}\n' "$reason"
        exit 0
      fi
    done < "$dir/protected-paths.tsv"
    ;;
esac
exit 0
