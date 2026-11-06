#!/usr/bin/env bash
# Feed every case in guard-cases.tsv as hook JSON to both PreToolUse hooks of hooks.json
# (guard.sh, then ngvu_guardrails.py for Bash/PowerShell) and compare the combined outcome:
# block when either blocks. Also runs the ngvu_guardrails.py self-test.
# Usage: run-guard-tests.sh     Exit: 0 all pass, 1 any failure.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
guard="$here/../hooks/guard.sh"
rails="$here/../hooks/ngvu_guardrails.py"
json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

tmp="$(mktemp -d)"
export KF_MACHINE_CONFIG="$tmp/none.json"  # never this machine's personalRoots
pass=0; fail=0
st="$(python -I "$rails" --self-test 2>&1)" && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL ngvu_guardrails self-test: $st"; }

# personalRoots comes from the machine config: a non-ticket push from D:\Personal passes only with it.
personal_json='{"tool_name":"Bash","cwd":"D:\\Personal\\demo","tool_input":{"command":"git push origin feat/x"}}'
echo '{"personalRoots":["D:/Personal"]}' > "$tmp/with.json"; echo '{"personalRoots":["D:/"]}' > "$tmp/drive.json"
for c in "with.json 0" "none.json 2" "drive.json 2"; do
  set -- $c
  printf '%s' "$personal_json" | KF_MACHINE_CONFIG="$tmp/$1" python -I "$rails" >/dev/null 2>&1; rc=$?
  if [ $rc -eq "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL personalRoots $1: exit $rc, expected $2"; fi
done
while IFS=$'\t' read -r expect tool arg; do
  case "$expect" in ''|\#*) continue ;; esac
  arg="${arg%$'\r'}"
  if [[ "$tool" =~ ^(Bash|PowerShell)$ ]]; then key=command; else key=file_path; fi
  json="{\"tool_name\":\"$tool\",\"tool_input\":{\"$key\":\"$(json_escape "$arg")\"}}"
  out="$(printf '%s' "$json" | bash "$guard" 2>/dev/null)"; rc=$?
  if [ $rc -eq 0 ] && [[ "$tool" =~ ^(Bash|PowerShell)$ ]]; then
    printf '%s' "$json" | python -I "$rails" >/dev/null 2>&1 || rc=$?
  fi
  if [ $rc -eq 2 ]; then got=block
  elif [ $rc -eq 0 ] && [[ "$out" == *'"permissionDecision":"ask"'* ]]; then got=ask
  elif [ $rc -eq 0 ]; then got=allow
  else got="error($rc)"; fi
  if [ "$got" = "$expect" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL expected=$expect got=$got [$tool] $arg"; fi
done < "$here/guard-cases.tsv"
echo "guard tests: $pass passed, $fail failed"
[ $fail -eq 0 ]
