source "$(dirname "$0")/lib/assert.sh"
# deploy/bootstrap.sh, doctor.sh, uninstall.sh against a temporary CLAUDE_HOME and a fake CLI.
T=$(kf_tmp); export CLAUDE_HOME="$T/home" STUB_STATE="$T/stub" CLAUDE_BIN="$KF_ROOT/tests/lib/claude-stub.sh"
unset KF_MACHINE_CONFIG
mkdir -p "$STUB_STATE" "$CLAUDE_HOME/skills/ngvu-factory" "$CLAUDE_HOME/skills/my-own-skill" "$CLAUDE_HOME/agents"
echo old > "$CLAUDE_HOME/skills/ngvu-factory/SKILL.md"; echo mine > "$CLAUDE_HOME/skills/my-own-skill/SKILL.md"
echo old > "$CLAUDE_HOME/agents/ngvu-builder.md"; echo old > "$CLAUDE_HOME/skills/PROJECT-STACK.md"
mkdir -p "$CLAUDE_HOME/hooks"; echo old > "$CLAUDE_HOME/hooks/ngvu_guardrails.py"
# install.sh left a user-level guard hook; another tool's hook shares the PreToolUse list
printf '{"skillOverrides": {"debug": "on"}, "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "rtk hook claude"}]}, {"matcher": "Bash|PowerShell", "hooks": [{"type": "command", "command": "python \\"C:/x/.claude/hooks/ngvu_guardrails.py\\""}]}]}}' > "$CLAUDE_HOME/settings.json"
B="$KF_ROOT/deploy/bootstrap.sh"; D="$KF_ROOT/deploy/doctor.sh"
j() { python -I -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8')); print(eval(sys.argv[2]))" "$(cygpath -m "$1")" "$2"; }

assert_exit 30 "Claude Code older than minClaudeVersion stops" env STUB_VERSION=2.1.200 bash "$B" --dry-run
assert_exit 1 "first install needs --team" bash "$B" --dry-run --workspace E:/Work/workspace
assert_exit 1 "--team is validated" bash "$B" --dry-run --team "My Team"
out=$(bash "$B" --dry-run --workspace E:/Work/workspace --team team-b </dev/null); rc=$?
assert_eq 0 "$rc" "dry run ok"
assert_contains "legacy   move     skills/ngvu-factory" "$out" "dry run lists the user-level copy to move"
assert_contains "(workspace E:/Work/workspace, team team-b)" "$out" "dry run lists the machine config"
assert_eq no "$([ -e "$CLAUDE_HOME/rules" ] || [ -e "$CLAUDE_HOME/ngvu-factory" ] && echo yes || echo no)" "dry run writes nothing"
assert_not_contains "marketplace add" "$(cat "$STUB_STATE/calls")" "dry run adds no marketplace"
assert_exit 16 "moving user-level copies needs confirmation when not interactive" bash "$B" --workspace E:/Work/workspace --team team-b

out=$(bash "$B" --yes --workspace E:/Work/workspace --team team-b </dev/null); rc=$?
assert_eq 0 "$rc" "bootstrap with --yes: $(tail -3 <<<"$out")"
calls=$(cat "$STUB_STATE/calls")
assert_contains "plugin marketplace add $(cygpath -m "$KF_ROOT") --scope user" "$calls" "marketplace source defaults to this clone"
for p in core-governance ngvu-factory ngvu-engineering; do
  assert_contains "plugin install $p@ngvu-ai-factory --scope user -y" "$calls" "installs $p at user scope"
done
assert_eq "" "$(diff -r "$KF_ROOT/plugins/core-governance/rules" "$CLAUDE_HOME/rules")" "rules installed"
assert_eq "E:/Work/workspace/tasks" "$(j "$CLAUDE_HOME/ngvu-factory/machine.json" "d['paths']['tasks']")" "machine config from --workspace"
assert_eq "team-b|team-b/|team-b|E:/Work/workspace" "$(j "$CLAUDE_HOME/ngvu-factory/machine.json" "'|'.join([d['team'], d['branchPrefix'], d['ownTeams'][0], d['workspace']])")" "machine config from --team"
assert_contains "OK    team: team-b" "$out" "doctor shows the team"
assert_eq "E:/Work/workspace/nextjs|nextjs" "$(j "$CLAUDE_HOME/ngvu-factory/machine.json" "'|'.join([d['paths']['repoRoots'][1]['path'], d['paths']['repoRoots'][1]['kind']])")" "machine config repo roots keep kinds"
assert_eq no "$([ -e "$CLAUDE_HOME/skills/ngvu-factory" ] && echo yes || echo no)" "user-level ngvu-factory moved aside"
assert_eq old "$(cat "$CLAUDE_HOME"/ngvu-legacy-*/agents/ngvu-builder.md)" "moved agent kept in ngvu-legacy-*"
assert_eq yes "$([ -e "$CLAUDE_HOME"/ngvu-legacy-*/skills/PROJECT-STACK.md ] && echo yes || echo no)" "old PROJECT-STACK.md moved aside"
assert_eq mine "$(cat "$CLAUDE_HOME/skills/my-own-skill/SKILL.md")" "skills the kit does not ship are untouched"
assert_eq on "$(j "$CLAUDE_HOME/settings.json" "d['skillOverrides']['debug']")" "a skill override the user set is kept"
assert_eq off "$(j "$CLAUDE_HOME/settings.json" "d['skillOverrides']['code-review']")" "kit skill overrides added"
assert_eq 13 "$(j "$CLAUDE_HOME/settings.json" "len(d['permissions']['deny'])")" "Jira write tools denied"
assert_eq "rtk hook claude" "$(j "$CLAUDE_HOME/settings.json" "'|'.join(h['command'] for e in d['hooks']['PreToolUse'] for h in e['hooks'])")" "user-level guard hook removed, other hooks kept"
assert_eq old "$(cat "$CLAUDE_HOME"/ngvu-legacy-*/hooks/ngvu_guardrails.py)" "old guard file moved aside"
assert_contains "OK    no user-level guard hook" "$out" "doctor confirms no user-level guard hook"
assert_contains "doctor: 0 failure(s)" "$out" "doctor passes after bootstrap"

echo '{"paths": {"tasks": "F:/mine"}}' > "$CLAUDE_HOME/ngvu-factory/machine.json"
echo edited >> "$CLAUDE_HOME/rules/approval-policy.md"
out=$(bash "$B" --yes </dev/null)
assert_contains "core-governance@ngvu-ai-factory updated" "$out" "second run updates instead of installing"
assert_eq "F:/mine" "$(j "$CLAUDE_HOME/ngvu-factory/machine.json" "d['paths']['tasks']")" "existing machine config kept"
assert_contains "edited" "$(cat "$CLAUDE_HOME"/rules.bak-*/approval-policy.md)" "a changed rule is backed up before it is replaced"
assert_eq "" "$(diff "$KF_ROOT/plugins/core-governance/rules/approval-policy.md" "$CLAUDE_HOME/rules/approval-policy.md")" "rule restored"

sed -i '/^ngvu-engineering@/d' "$STUB_STATE/plugins"
out=$(bash "$D"); rc=$?
assert_eq 1 "$rc" "doctor fails when a plugin is missing"
assert_contains "FAIL  plugin ngvu-engineering@ngvu-ai-factory not installed" "$out" "doctor names the missing plugin"
out=$(bash "$KF_ROOT/deploy/uninstall.sh" --dry-run)
assert_contains "plugin uninstall ngvu-factory@ngvu-ai-factory --scope user" "$out" "uninstall dry run lists the commands"
assert_eq 2 "$(wc -l < "$STUB_STATE/plugins" | tr -d ' ')" "uninstall dry run changes nothing"
bash "$KF_ROOT/deploy/uninstall.sh" >/dev/null
assert_eq 0 "$(wc -l < "$STUB_STATE/plugins" | tr -d ' ')" "uninstall removes the plugins"
assert_eq yes "$([ -f "$CLAUDE_HOME/ngvu-factory/machine.json" ] && echo yes || echo no)" "uninstall keeps the machine config"
kf_finish
