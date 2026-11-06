#!/usr/bin/env bash
# Remove the kit's plugins and marketplace from this machine. Keeps ~/.claude/rules, the machine
# config, settings.json entries and any ngvu-legacy-*/ backup, and says where they are, so a user
# can restore the old user-level setup by moving ngvu-legacy-<time>/* back.
# Usage: uninstall.sh [--dry-run]      Env: CLAUDE_HOME, CLAUDE_BIN as bootstrap.sh.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE="${CLAUDE_BIN:-claude}"
source "$ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts/lib.sh"
DRY=0; [ "${1:-}" = --dry-run ] && DRY=1
py="$(kf_python)" || exit 1
kit() { "$py" -c 'import json,sys; v=json.load(open(sys.argv[1],encoding="utf-8"))[sys.argv[2]]; print("\n".join(v) if isinstance(v,list) else v)' "$(kf_native_path "$ROOT/deploy/kit.json")" "$1" | tr -d '\r'; }
MKT="$(kit marketplace)"
run() { echo "  $*"; [ $DRY -eq 1 ] || "$@"; }

while IFS= read -r p; do
  [ -n "$p" ] && run "$CLAUDE" plugin uninstall "$p@$MKT" --scope user
done <<< "$(kit plugins)"
run "$CLAUDE" plugin marketplace remove "$MKT"
echo "Kept (remove by hand if you want): $DEST/rules/*.md from the kit, $DEST/ngvu-factory/,"
echo "settings.json denies and skillOverrides, backups $DEST/rules.bak-*/ and $DEST/ngvu-legacy-*/."
