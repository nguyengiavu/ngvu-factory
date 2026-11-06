#!/usr/bin/env bash
# Read-only health check of the ngvu factory on this machine. Prints OK / WARN / FAIL per line.
# Usage: doctor.sh      Env: CLAUDE_HOME, CLAUDE_BIN as bootstrap.sh.
# Exit: 0 no FAIL, 1 at least one FAIL.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE="${CLAUDE_BIN:-claude}"
export KF_MACHINE_CONFIG="${KF_MACHINE_CONFIG:-$DEST/ngvu-factory/machine.json}"
source "$ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/lib.sh"
fails=0
ok() { echo "OK    $*"; }
warn() { echo "WARN  $*"; }
fail() { echo "FAIL  $*"; fails=$((fails+1)); }

py="$(kf_python 2>/dev/null)" && ok "python: $py" || fail "no working python (the guardrail hook needs one; install Python 3 and put it on PATH as python)"
command -v python >/dev/null && python -c 'import sys' 2>/dev/null && ok "hook command 'python' runs" \
  || fail "'python' does not run: the core-governance hook calls 'python', so with onFailure block every Bash/PowerShell call will be blocked"
command -v git >/dev/null && ok "git: $(git --version)" || fail "git not found"
ver="$("$CLAUDE" --version 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')" && ok "Claude Code $ver" || fail "Claude Code CLI not found"
[ -z "$py" ] && { echo "doctor: $fails failure(s)"; exit 1; }
kit() { "$py" -c 'import json,sys; v=json.load(open(sys.argv[1],encoding="utf-8"))[sys.argv[2]]; print("\n".join(v) if isinstance(v,list) else v)' "$(kf_native_path "$ROOT/deploy/kit.json")" "$1" | tr -d '\r'; }
MKT="$(kit marketplace)"

"$CLAUDE" plugin marketplace list 2>/dev/null | grep -qE "❯ $MKT\$" && ok "marketplace $MKT" || fail "marketplace $MKT not added (run deploy/bootstrap)"
installed="$("$CLAUDE" plugin list 2>/dev/null)"
while IFS= read -r p; do
  [ -n "$p" ] || continue
  grep -qE "❯ $p@$MKT\$" <<<"$installed" && ok "plugin $p@$MKT" || fail "plugin $p@$MKT not installed"
done <<< "$(kit plugins)"

for f in "$ROOT/$(kit rulesFrom)"/*.md; do
  t="$DEST/rules/$(basename "$f")"
  if [ ! -e "$t" ]; then fail "rule $(basename "$f") missing in $DEST/rules"
  elif ! cmp -s "$f" "$t"; then warn "rule $(basename "$f") differs from this clone (edited locally, or the clone is newer: re-run bootstrap)"
  else ok "rule $(basename "$f")"; fi
done

if [ -f "$KF_MACHINE_CONFIG" ]; then
  cfg="$(kf_config_path)" && ok "machine config $KF_MACHINE_CONFIG" || fail "machine config invalid: $KF_MACHINE_CONFIG"
  for k in workspace team factoryRepo; do
    "$py" -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1],encoding="utf-8-sig")) else 1)' "$(kf_native_path "$KF_MACHINE_CONFIG")" "$k" 2>/dev/null       && ok "$k: $(kf_cfg "$k")" || warn "$k not set in $KF_MACHINE_CONFIG: the bundled default $(kf_cfg "$k" 2>/dev/null) is used (add \"$k\" there)"
  done
  ok "branch prefix: $(kf_cfg branchPrefix)"
  while IFS=$'\t' read -r root kind; do
    [ -d "$root" ] && ok "repo root $root ($kind)" || warn "repo root $root ($kind) does not exist"
  done < <(KF_CONFIG="$cfg" "$py" -c 'import json,sys; [print("%s\t%s" % (r["path"], r["kind"])) for r in json.load(open(sys.argv[1],encoding="utf-8"))["paths"]["repoRoots"]]' "$(kf_native_path "$cfg")" | tr -d '\r')
  for k in paths.tasks paths.worktrees; do
    v="$(kf_cfg "$k")"; [ -d "$v" ] && ok "$k $v" || warn "$k $v does not exist yet"
  done
  u="$(kf_cfg unitTest.java-service)"
  case "$u" in
    *.bat|*.cmd|*.sh) [ -f "$u" ] && ok "unit-test script $u" || warn "unit-test script $u not found" ;;
    *) command -v "${u%% *}" >/dev/null 2>&1 && ok "unit-test command: $u" || warn "unit-test command not on PATH: ${u%% *}" ;;
  esac
  ok "report language: $(kf_cfg reportLanguage 2>/dev/null || echo en)"
else
  fail "no machine config $KF_MACHINE_CONFIG (run deploy/bootstrap)"
fi

out="$("$py" -I "$ROOT/plugins/core-governance/hooks/ngvu_guardrails.py" --self-test 2>&1)" && ok "guardrail self-test: $out" || fail "guardrail self-test: $out"
"$py" -c 'import json,sys; d=json.load(open(sys.argv[1],encoding="utf-8-sig")); sys.exit(0 if any("Atlassian__editJiraIssue" in x for x in d.get("permissions",{}).get("deny",[])) else 1)' \
  "$(kf_native_path "$DEST/settings.json")" 2>/dev/null && ok "Jira write tools denied" || fail "Atlassian MCP write tools are not denied in $DEST/settings.json"

for d in "$ROOT"/plugins/*/skills/*/; do
  n="$(basename "$d")"; [ -e "$DEST/skills/$n" ] && warn "user-level skill $n still exists next to the plugin copy (offered twice)"
done
for a in "$ROOT"/plugins/*/agents/*.md; do
  n="$(basename "$a")"; [ -e "$DEST/agents/$n" ] && warn "user-level agent $n still exists next to the plugin copy"
done
"$py" -c 'import json,sys; d=json.load(open(sys.argv[1],encoding="utf-8-sig")); sys.exit(1 if any("ngvu_guardrails.py" in h.get("command","") for e in d.get("hooks",{}).get("PreToolUse",[]) for h in e.get("hooks",[])) else 0)' \
  "$(kf_native_path "$DEST/settings.json")" 2>/dev/null && ok "no user-level guard hook (the plugin ships it)" \
  || warn "settings.json registers a user-level ngvu_guardrails.py hook next to the plugin's (or is unreadable): re-run bootstrap"
grep -qE "❯ superpowers@" <<<"$installed" && ok "superpowers plugin (slots.yaml owner of bugs.diagnose)" \
  || warn "superpowers plugin missing: /plugin install superpowers@claude-plugins-official (optional; to use your own debugging skill instead see guide/USER-GUIDE.md \"Without superpowers\")"
command -v gitleaks >/dev/null 2>&1 && ok "gitleaks $(gitleaks version 2>/dev/null) (secret scan of commits)" \
  || warn "gitleaks missing (optional; needed to publish the kit or to scan a branch): winget install Gitleaks.Gitleaks"

echo "doctor: $fails failure(s)"
[ $fails -eq 0 ]
