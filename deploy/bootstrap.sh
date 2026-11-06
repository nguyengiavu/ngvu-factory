#!/usr/bin/env bash
# Set up the ngvu factory on this machine from this clone (see deploy/README.md).
#   1. prerequisites: git, a working python, Claude Code >= kit.json minClaudeVersion
#   2. marketplace kit.json "marketplace" from --source (default: this clone, loaded in place)
#   3. plugins kit.json "plugins" at user scope
#   4. rules: plugins/core-governance/rules/*.md -> ~/.claude/rules (changed files backed up)
#   5. machine config ~/.claude/ngvu-factory/machine.json from --workspace and --team (kept if it
#      exists): workspace, factoryRepo (this clone), team, branchPrefix, ownTeams, paths
#   6. settings.json: Atlassian MCP write denies + kit skillOverrides; unregisters install.sh's user-level
#      ngvu_guardrails.py hook (the plugin ships the guard) (tools/install_settings.py)
#   7. user-level copies of skills/agents the plugins now ship -> ~/.claude/ngvu-legacy-<time>/
#   8. doctor
# Usage: bootstrap.sh --team <team> [--source <git url|dir>] [--workspace <dir>] [--dry-run] [--yes] [--keep-legacy]
#        --team is required only when the machine config does not exist yet (e.g. ngvu, team-b).
# Env: CLAUDE_HOME (default ~/.claude), CLAUDE_BIN (default claude).
# Exit: 0 ok, 1 usage or a failed step, 16 changes need confirmation (not a terminal, no --yes),
#       30 prerequisite missing.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE="${CLAUDE_BIN:-claude}"
source "$ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/lib.sh"

SOURCE=""; WS=""; TEAM=""; DRY=0; YES=0; LEGACY=1
while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE="${2:-}"; shift ;;
    --workspace) WS="${2:-}"; shift ;;
    --team) TEAM="${2:-}"; shift ;;
    --dry-run) DRY=1 ;;
    --yes) YES=1 ;;
    --keep-legacy) LEGACY=0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

py="$(kf_python)" || exit 30
kit() { "$py" -c 'import json,sys; v=json.load(open(sys.argv[1],encoding="utf-8"))[sys.argv[2]]; print("\n".join(v) if isinstance(v,list) else v)' "$(kf_native_path "$ROOT/deploy/kit.json")" "$1" | tr -d '\r'; }
MKT="$(kit marketplace)"; WS="${WS:-$(kit defaultWorkspace)}"; WS="${WS%/}"
[ -n "$SOURCE" ] || SOURCE="$(kf_native_path "$ROOT")"
say() { echo "[$1] $2"; }

# 1. prerequisites
command -v git >/dev/null || { echo "git not found: install Git for Windows" >&2; exit 30; }
ver="$("$CLAUDE" --version 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')" || true
[ -n "$ver" ] || { echo "Claude Code CLI not found ($CLAUDE)" >&2; exit 30; }
"$py" -c 'import sys; t=lambda s: tuple(map(int,s.split("."))); sys.exit(t(sys.argv[1]) < t(sys.argv[2]))' "$ver" "$(kit minClaudeVersion)" \
  || { echo "Claude Code $ver is older than $(kit minClaudeVersion) (guards need onFailure: block); run: claude update" >&2; exit 30; }
say 1 "git, $py, Claude Code $ver"

# Plan the file changes first, so one confirmation covers them.
stamp="$(date +%Y%m%d-%H%M%S)"
rules_new=(); rules_changed=()
for f in "$ROOT/$(kit rulesFrom)"/*.md; do
  t="$DEST/rules/$(basename "$f")"
  if [ ! -e "$t" ]; then rules_new+=("$f"); elif ! cmp -s "$f" "$t"; then rules_changed+=("$f"); fi
done
legacy=()
if [ $LEGACY -eq 1 ]; then
  for d in "$ROOT"/plugins/*/skills/*/; do
    n="$(basename "$d")"; [ -e "$DEST/skills/$n" ] && legacy+=("skills/$n")
  done
  [ -e "$DEST/skills/PROJECT-STACK.md" ] && legacy+=("skills/PROJECT-STACK.md")
  # install.sh's user-level guard; the plugin ships it and step 6 unregisters the old one
  [ -e "$DEST/hooks/ngvu_guardrails.py" ] && legacy+=("hooks/ngvu_guardrails.py")
  for a in "$ROOT"/plugins/*/agents/*.md; do
    n="$(basename "$a")"; [ -e "$DEST/agents/$n" ] && legacy+=("agents/$n")
  done
fi
machine="$DEST/ngvu-factory/machine.json"
if [ ! -e "$machine" ]; then
  [ -n "$TEAM" ] || { echo "first install on this machine: pass --team <your team name> (e.g. ngvu); it names your branches <team>/vung-<n>-..." >&2; exit 1; }
  [[ "$TEAM" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "--team must be lower-case letters, digits and '-': $TEAM" >&2; exit 1; }
fi

echo "ngvu-ai-factory bootstrap -> $DEST (marketplace source: $SOURCE)"
for f in "${rules_new[@]}"; do echo "  rules    new      $(basename "$f")"; done
for f in "${rules_changed[@]}"; do echo "  rules    changed  $(basename "$f") (old copy -> rules.bak-$stamp/)"; done
for l in "${legacy[@]}"; do echo "  legacy   move     $l -> ngvu-legacy-$stamp/$l"; done
[ -e "$machine" ] && echo "  machine  keep     $machine" || echo "  machine  new      $machine (workspace $WS, team $TEAM)"
"$py" "$ROOT/tools/install_settings.py" "$(kf_native_path "$DEST")" --dry-run --no-hook --skill-overrides "$(kf_native_path "$ROOT/deploy/kit.json")" || exit 1
if [ $DRY -eq 1 ]; then echo "Dry run: nothing written, no plugin installed."; exit 0; fi

if { [ ${#rules_changed[@]} -gt 0 ] || [ ${#legacy[@]} -gt 0 ]; } && [ $YES -eq 0 ]; then
  if [ -t 0 ]; then
    read -r -p "Replace ${#rules_changed[@]} rule file(s) and move ${#legacy[@]} user-level item(s) aside? [y/N] " ans
    [ "$ans" = y ] || [ "$ans" = Y ] || { echo "Aborted."; exit 16; }
  else
    echo "Changed rules or user-level copies exist; re-run in a terminal or with --yes." >&2; exit 16
  fi
fi

# 2. marketplace
if "$CLAUDE" plugin marketplace list 2>/dev/null | grep -qE "❯ $MKT\$"; then
  "$CLAUDE" plugin marketplace update "$MKT" >/dev/null || { echo "marketplace update failed" >&2; exit 1; }
  say 2 "marketplace $MKT updated"
else
  "$CLAUDE" plugin marketplace add "$SOURCE" --scope user >/dev/null || { echo "marketplace add failed: $SOURCE" >&2; exit 1; }
  say 2 "marketplace $MKT added from $SOURCE"
fi

# 3. plugins
installed="$("$CLAUDE" plugin list 2>/dev/null)"
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if grep -qE "❯ $p@$MKT\$" <<<"$installed"; then
    "$CLAUDE" plugin update "$p@$MKT" --scope user >/dev/null || { echo "update failed: $p" >&2; exit 1; }
    say 3 "$p@$MKT updated"
  else
    "$CLAUDE" plugin install "$p@$MKT" --scope user -y >/dev/null || { echo "install failed: $p" >&2; exit 1; }
    say 3 "$p@$MKT installed"
  fi
done <<< "$(kit plugins)"

# 4. rules
mkdir -p "$DEST/rules" || exit 1
for f in "${rules_changed[@]}"; do
  mkdir -p "$DEST/rules.bak-$stamp" && cp "$DEST/rules/$(basename "$f")" "$DEST/rules.bak-$stamp/" || exit 1
done
for f in "${rules_new[@]}" "${rules_changed[@]}"; do cp "$f" "$DEST/rules/" || exit 1; done
say 4 "rules: ${#rules_new[@]} new, ${#rules_changed[@]} replaced"

# 5. machine config
if [ ! -e "$machine" ]; then
  mkdir -p "$(dirname "$machine")" && "$py" -c '
import json, sys
ws, team, kit = sys.argv[1], sys.argv[3], sys.argv[4]
cfg = {"workspace": ws, "factoryRepo": kit,
       "team": team, "branchPrefix": team + "/", "ownTeams": [team],
       "paths": {"repoRoots": [{"path": ws + "/services", "kind": "java-service"},
                               {"path": ws + "/nextjs", "kind": "nextjs"}],
                 "tasks": ws + "/tasks", "worktrees": ws + "/.ngvu-worktrees"}}
json.dump(cfg, open(sys.argv[2], "w", encoding="utf-8"), indent=2)
' "$WS" "$(kf_native_path "$machine")" "$TEAM" "$(kf_native_path "$ROOT")" || { echo "cannot write $machine" >&2; exit 1; }
  say 5 "machine config written for workspace $WS, team $TEAM (branches $TEAM/...)"
else
  say 5 "machine config kept: $machine"
fi

# 6. settings.json
"$py" "$ROOT/tools/install_settings.py" "$(kf_native_path "$DEST")" --no-hook --skill-overrides "$(kf_native_path "$ROOT/deploy/kit.json")" >/dev/null \
  || { echo "settings.json update failed" >&2; exit 1; }
say 6 "settings.json: Jira write denies and skill overrides present, no user-level guard hook"

# 7. user-level copies the plugins replace (moved, never deleted)
for l in "${legacy[@]}"; do
  mkdir -p "$DEST/ngvu-legacy-$stamp/$(dirname "$l")" && mv "$DEST/$l" "$DEST/ngvu-legacy-$stamp/$l" || { echo "cannot move $l" >&2; exit 1; }
done
[ ${#legacy[@]} -gt 0 ] && say 7 "${#legacy[@]} user-level item(s) moved to $DEST/ngvu-legacy-$stamp" || say 7 "no user-level copies to move"

# 8. doctor
bash "$ROOT/deploy/doctor.sh"
