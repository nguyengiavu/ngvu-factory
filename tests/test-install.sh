source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); export CLAUDE_HOME="$T/claude"; I="$KF_ROOT/install.sh"
mkdir -p "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/__pycache__"; touch "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/__pycache__/kf_probe.pyc"
out=$(bash "$I" --dry-run </dev/null); rc=$?
rm -rf "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/__pycache__"
assert_eq no "$(grep -q kf_probe <<<"$out" && echo yes || echo no)" "python bytecode is not installed"
assert_eq 0 "$rc" "dry run ok"
assert_contains "new" "$out" "dry run lists new files"
assert_eq no "$([ -e "$CLAUDE_HOME" ] && echo yes || echo no)" "dry run writes nothing"
assert_exit 0 "first install" bash "$I" </dev/null
assert_eq yes "$([ -f "$CLAUDE_HOME/skills/ngvu-factory/SKILL.md" ] && echo yes || echo no)" "skill installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/skills/ngvu-factory/factory.config.json" ] && echo yes || echo no)" "config installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/agents/ngvu-builder.md" ] && echo yes || echo no)" "agents installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/agents/ngvu-reviewer-frontend-ui.md" ] && echo yes || echo no)" "fifth lens installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/skills/ngvu-triage/SKILL.md" ] && echo yes || echo no)" "ngvu-triage installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/skills/ngvu-ticket-investigation/SKILL.md" ] && echo yes || echo no)" "investigation skill installed"
assert_eq yes "$([ -f "$CLAUDE_HOME/skills/ngvu-epic-investigation/SKILL.md" ] && echo yes || echo no)" "epic investigation skill installed"
assert_eq no "$([ -e "$CLAUDE_HOME/skills/ngvu-factory/evals" ] || [ -e "$CLAUDE_HOME/evals" ] && echo yes || echo no)" "evals stay in the repo"
assert_contains "Already up to date" "$(bash "$I" </dev/null)" "second run is a no-op"
echo "local edit" >> "$CLAUDE_HOME/agents/ngvu-builder.md"
assert_exit 16 "changed file needs confirmation when not interactive" bash "$I" </dev/null
assert_exit 0 "--yes overwrites" bash "$I" --yes </dev/null
assert_eq "" "$(diff "$KF_ROOT/plugins/ngvu-factory/agents/ngvu-builder.md" "$CLAUDE_HOME/agents/ngvu-builder.md")" "file restored"
assert_eq "ngvu/" "$(KF_CONFIG= bash -c "source '$CLAUDE_HOME/skills/ngvu-factory/scripts/lib.sh'; kf_cfg branchPrefix")" "installed scripts find installed config"
assert_exit 1 "unknown option" bash "$I" --force
# Guardrails: hook file installed and registered, deny rules added, other settings kept.
S="$CLAUDE_HOME/settings.json"
assert_eq yes "$([ -f "$CLAUDE_HOME/hooks/ngvu_guardrails.py" ] && echo yes || echo no)" "guardrail hook installed"
j() { python -I -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8')); print(eval(sys.argv[2]))" "$(cygpath -m "$S")" "$1"; }
assert_eq 1 "$(j "sum('ngvu_guardrails.py' in h['command'] for e in d['hooks']['PreToolUse'] for h in e['hooks'])")" "hook registered once"
assert_eq "Bash|PowerShell" "$(j "[e['matcher'] for e in d['hooks']['PreToolUse']][0]")" "hook covers Bash and PowerShell"
assert_eq 13 "$(j "len(d['permissions']['deny'])")" "Atlassian MCP write tools denied"
T2=$(kf_tmp); mkdir -p "$T2/claude"
printf '{"theme":"dark","permissions":{"defaultMode":"auto","deny":["Bash(rm:*)"]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"rtk hook claude"}]}]}}' > "$T2/claude/settings.json"
out=$(CLAUDE_HOME="$T2/claude" bash "$I" --dry-run </dev/null)
assert_contains "settings hook" "$out" "dry run shows the planned hook"
assert_contains '"theme":"dark"' "$(cat "$T2/claude/settings.json")" "dry run leaves settings.json untouched"
CLAUDE_HOME="$T2/claude" bash "$I" </dev/null >/dev/null
S="$T2/claude/settings.json"
assert_eq "dark|auto|Bash(rm:*)|rtk hook claude" "$(j "'|'.join([d['theme'], d['permissions']['defaultMode'], d['permissions']['deny'][0], d['hooks']['PreToolUse'][0]['hooks'][0]['command']])")" "existing settings kept"
assert_eq 14 "$(j "len(d['permissions']['deny'])")" "deny rules appended"
assert_eq yes "$([ -f "$S.bak-ngvu-factory" ] && echo yes || echo no)" "settings backed up before the change"
assert_contains "Already up to date" "$(CLAUDE_HOME="$T2/claude" bash "$I" </dev/null)" "second run adds nothing"
T3=$(kf_tmp); CLAUDE_HOME="$T3/claude" bash "$I" --no-guardrails </dev/null >/dev/null
assert_eq no "$([ -f "$T3/claude/settings.json" ] && echo yes || echo no)" "--no-guardrails leaves settings.json alone"
mkdir -p "$T3/x"; echo '{broken' > "$T3/x/settings.json"
assert_exit 1 "invalid settings.json stops the install" env CLAUDE_HOME="$T3/x" bash "$I" --dry-run
assert_eq "{broken" "$(cat "$T3/x/settings.json")" "invalid settings.json left untouched"
kf_finish
