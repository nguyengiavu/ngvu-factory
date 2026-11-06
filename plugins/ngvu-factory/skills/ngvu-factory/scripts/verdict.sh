#!/usr/bin/env bash
# Read the line-1 verdict of a factory file.
# Usage: verdict.sh <review|build|decision|spec|it|verify> <file>
# Prints PASS|CHANGES (review), READY|BLOCKED (build, spec), APPROVE|ESCALATE (decision),
# PASS|FAIL|WAIVED (it), OK|PROBLEM|INCOMPLETE (verify).
# Exit: 0 ok, 2 missing file or malformed first line, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

kind="${1:-}"; f="${2:-}"
[ -n "$f" ] || kf_die "usage: verdict.sh <review|build|decision|spec|it|verify> <file>"
[ -f "$f" ] || { echo "missing: $f" >&2; exit 2; }
line=$(head -n1 "$f" | sed $'1s/^\xEF\xBB\xBF//' | tr -d '\r' | sed 's/[[:space:]]*$//')
case "$kind:$line" in
  "review:VERDICT: PASS")    echo PASS ;;
  "review:VERDICT: CHANGES") echo CHANGES ;;
  "build:STATUS: READY")     echo READY ;;
  "build:STATUS: BLOCKED")   echo BLOCKED ;;
  "decision:APPROVE")        echo APPROVE ;;
  "decision:ESCALATE")       echo ESCALATE ;;
  "spec:STATUS: BLOCKED")    echo BLOCKED ;;
  "spec:# "*)                echo READY ;;
  "it:IT: PASS")             echo PASS ;;
  "it:IT: FAIL")             echo FAIL ;;
  "it:IT: WAIVED")           echo WAIVED ;;
  "verify:VERIFY: OK")         echo OK ;;
  "verify:VERIFY: PROBLEM")    echo PROBLEM ;;
  "verify:VERIFY: INCOMPLETE") echo INCOMPLETE ;;
  *) echo "malformed first line in $f: [$line]" >&2; exit 2 ;;
esac
