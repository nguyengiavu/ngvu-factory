#!/usr/bin/env bash
# User-level install of the factory into ~/.claude (or $CLAUDE_HOME): the alternative to the plugin
# install in README.md. Use one of the two, never both, or every skill and agent is offered twice.
# Copies plugins/ngvu-factory/skills/* to skills/, plugins/ngvu-factory/agents/*.md to agents/,
# and plugins/core-governance/hooks/ngvu_guardrails.py to hooks/, then registers that hook and the
# Atlassian MCP write denies in settings.json (tools/install_settings.py).
# Usage: install.sh [--dry-run] [--yes] [--no-guardrails]
#   --dry-run        show what would be copied, write nothing
#   --yes            overwrite changed files without asking
#   --no-guardrails  do not register the guardrail hook and Jira-write denies in settings.json
# Exit: 0 ok or up to date, 16 changed files need confirmation, 1 bad option.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
DRY=0; YES=0; GUARD=1
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --yes) YES=1 ;;
    --no-guardrails) GUARD=0 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

KF="$ROOT/plugins/ngvu-factory"
pairs=()
while IFS= read -r f; do pairs+=("$f|$DEST/skills/${f#"$KF/skills/"}"); done < <(find "$KF/skills" -name __pycache__ -prune -o -type f ! -name "*.pyc" -print | sort)
for f in "$KF"/agents/*.md; do pairs+=("$f|$DEST/agents/$(basename "$f")"); done
pairs+=("$ROOT/plugins/core-governance/hooks/ngvu_guardrails.py|$DEST/hooks/ngvu_guardrails.py")

new=(); changed=()
for p in "${pairs[@]}"; do
  s="${p%%|*}"; t="${p#*|}"
  if [ ! -e "$t" ]; then new+=("$t"); elif ! cmp -s "$s" "$t"; then changed+=("$t"); fi
done

# settings.json: planned now, applied after the copy.
settings_plan=""
if [ $GUARD -eq 1 ]; then
  source "$KF/skills/ngvu-factory/scripts/lib.sh"
  py="$(kf_python)" || exit 1
  settings_plan=$("$py" "$ROOT/tools/install_settings.py" "$(kf_native_path "$DEST")" --dry-run) || exit 1
fi

echo "ngvu-ai-factory install -> $DEST"
for t in "${new[@]}"; do echo "  new      $t"; done
for t in "${changed[@]}"; do echo "  changed  $t"; done
[ -n "$settings_plan" ] && printf '%s\n' "$settings_plan"
if [ ${#new[@]} -eq 0 ] && [ ${#changed[@]} -eq 0 ] && [ -z "$settings_plan" ]; then echo "Already up to date."; exit 0; fi
if [ $DRY -eq 1 ]; then echo "Dry run: nothing written."; exit 0; fi

if [ ${#changed[@]} -gt 0 ] && [ $YES -eq 0 ]; then
  if [ -t 0 ]; then
    read -r -p "Overwrite ${#changed[@]} changed file(s)? [y/N] " ans
    [ "$ans" = y ] || [ "$ans" = Y ] || { echo "Aborted."; exit 16; }
  else
    echo "Changed files exist; re-run in a terminal or with --yes." >&2; exit 16
  fi
fi

for p in "${pairs[@]}"; do
  s="${p%%|*}"; t="${p#*|}"
  mkdir -p "$(dirname "$t")" && cp "$s" "$t" || { echo "copy failed: $t" >&2; exit 1; }
done
if [ -n "$settings_plan" ]; then
  "$py" "$ROOT/tools/install_settings.py" "$(kf_native_path "$DEST")" || { echo "settings.json update failed" >&2; exit 1; }
  echo "Guardrails registered in $DEST/settings.json (backup: settings.json.bak-ngvu-factory)."
fi
echo "Installed. Open a new Claude Code session and run: /ngvu-factory status"
