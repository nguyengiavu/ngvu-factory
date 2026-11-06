#!/usr/bin/env bash
# selftest.sh — test breakdown.sh and new-epic.sh/new-child.sh in a temp folder. Run after changing a script.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
check() { # check <name> <expected exit> <command...>
  local name="$1" want="$2"; shift 2
  "$@" >"$T/out" 2>&1; local got=$?
  if [ "$got" = "$want" ]; then echo "ok   $name"; else echo "FAIL $name (exit $got, expected $want)"; cat "$T/out"; fail=1; fi
}
mk() { # mk <folder> <table rows after the header>
  mkdir -p "$1"
  printf '## 2. Actual requirements (R-list)\n| # | Requirement | Basis |\n|---|---|---|\n| **R1** | a | x |\n| R2 | b | y |\n## 3. Other\n| R9 | not counted | |\n' > "$1/01-EPIC-AND-CONTEXT.md"
  printf '## Factory queue\n| Story | Jira | Summary | Repos | Owner | Blocked by | Covers |\n|---|---|---|---|---|---|---|\n%b## After\n' "$2" > "$1/08-STORY-BREAKDOWN.md"
}
mk "$T/ok"    '| S1 | VUNG-1 | a | example_core | ngvu | — | R1 |\n| S2 | — | b | example_core, example_web | team-b | S1, VUNG-9 | R2 |\n'
mk "$T/gap"   '| S1 | VUNG-1 | a | example_core | ngvu | — | R1 |\n'
mk "$T/cycle" '| S1 | VUNG-1 | a | example_core | t | VUNG-2 | R1 |\n| S2 | VUNG-2 | b | example_core | t | S1 | R2 |\n'
mk "$T/ref"   '| S1 | VUNG-1 | a | example_core | t | S7 | R1, R2 |\n'
check "valid table"              0 bash "$HERE/breakdown.sh" "$T/ok"
check "R2 not covered"           2 bash "$HERE/breakdown.sh" "$T/gap"
check "dependency cycle"         2 bash "$HERE/breakdown.sh" "$T/cycle"
check "Blocked by does not exist" 2 bash "$HERE/breakdown.sh" "$T/ref"
check "missing Factory queue section" 3 bash "$HERE/breakdown.sh" "$HERE"
bash "$HERE/breakdown.sh" "$T/ok" --json > "$T/j" 2>/dev/null
grep -q '"blockedByKeys": \[' "$T/j" && grep -q '"VUNG-9"' "$T/j" && grep -q '"S1"' "$T/j" \
  && echo "ok   JSON has blockedByKeys" || { echo "FAIL JSON"; cat "$T/j"; fail=1; }

check "new-epic scaffolds"       0 bash "$HERE/new-epic.sh" 900001 demo-epic --title "Demo" --root "$T/k"
[ -f "$T/k/tasks/EPIC-VUNG-900001-demo-epic/08-STORY-BREAKDOWN.md" ] && [ -f "$T/k/tasks/EPIC-VUNG-900001-demo-epic/diagrams/presentation.html" ] \
  && echo "ok   scaffold has all files" || { echo "FAIL scaffold is missing files"; fail=1; }
check "unfilled scaffold rejected by breakdown" 2 bash "$HERE/breakdown.sh" "$T/k/tasks/EPIC-VUNG-900001-demo-epic"
check "new-epic refuses a duplicate number" 1 bash "$HERE/new-epic.sh" 900001 other --root "$T/k"
check "new-child scaffolds at the tasks level" 0 bash "$HERE/new-child.sh" 900001 900002 demo-child --root "$T/k"
grep -q 'EPIC-VUNG-900001-demo-epic' "$T/k/tasks/VUNG-900002-demo-child/README.md" \
  && echo "ok   child README points to the epic" || { echo "FAIL child README"; fail=1; }
NT="$HERE/../../ngvu-ticket-investigation/scripts/new-task.sh"
check "new-task refuses a number that has a child folder" 1 bash "$NT" 900002 other --root "$T/k"
check "new-task refuses a number that is an epic"         1 bash "$NT" 900001 other --root "$T/k"
bash "$HERE/breakdown.sh" "$T/ok" 2>&1 | grep -q "S1 (VUNG-1) has no child folder" \
  && echo "ok   warning for a keyed story without a child folder" || { echo "FAIL child folder warning"; fail=1; }
mkdir -p "$T/VUNG-1-a"
bash "$HERE/breakdown.sh" "$T/ok" 2>&1 | grep -q "has no child folder" \
  && { echo "FAIL still warns when the child folder exists"; fail=1; } || echo "ok   no warning once the child folder exists"
exit $fail
