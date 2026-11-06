#!/usr/bin/env bash
# new-epic.sh — scaffold the standard investigation folder for a VUNG EPIC.
#
#   bash new-epic.sh <epic-number> <kebab-slug> [--title "..."] [--root <workspace>]
#   bash new-epic.sh 100002 example-epic --title "Example epic title"
#
# Result: <tasks>/EPIC-VUNG-<number>-<slug>/  (README, 01..13, evidence/, diagrams/)
# The EPIC- prefix puts every epic first when sorted by name; child tickets sit at the same level (VUNG-<n>-<slug>).
# Refuses if this number already has a folder (EPIC-VUNG-<number>* or VUNG-<number>*): /ngvu-factory would not know which to pick.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$HERE/../templates"
DIAG="$HERE/../../ngvu-ticket-investigation/templates/diagrams"   # shares the presentation with the ticket skill
source "$HERE/../../ngvu-ticket-investigation/scripts/workspace.sh"

NUM=""; SLUG=""; TITLE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --root)  ROOT="$2"; TASKS="$ROOT/tasks"; shift 2 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) if [ -z "$NUM" ]; then NUM="${1#VUNG-}"; NUM="${NUM#vung-}"; else SLUG="$1"; fi; shift ;;
  esac
done
{ [[ "$NUM" =~ ^[0-9]+$ ]] && [[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; } \
  || { echo "Usage: $0 <epic-number> <lowercase-kebab-slug> [--title '...']" >&2; exit 1; }

KEY="VUNG-$NUM"
NAME="EPIC-$KEY-$SLUG"
DIR="$TASKS/$NAME"
DATE="$(date +%Y-%m-%d)"
[ -n "$TITLE" ] || TITLE="$KEY"

shopt -s nullglob
existing=( "$TASKS/EPIC-$KEY" "$TASKS/EPIC-$KEY-"* "$TASKS/$KEY" "$TASKS/$KEY-"* )
shopt -u nullglob
found=""; for p in "${existing[@]}"; do [ -d "$p" ] && found="$found  $(basename "$p")"$'\n'; done
if [ -n "$found" ]; then
  echo "$KEY already has a folder:" >&2; printf '%s' "$found" >&2
  echo "Reopen that folder, or rename it (the user decides) and run again. The script does not overwrite." >&2
  exit 1
fi
[ -d "$TPL" ] && [ -d "$DIAG" ] || { echo "Missing templates: $TPL or $DIAG" >&2; exit 1; }

mkdir -p "$DIR/diagrams" "$DIR/evidence"
subst() {
  sed -e "s|{{EPIC}}|$KEY|g" -e "s|{{TICKET}}|$KEY|g" -e "s|{{NUM}}|$NUM|g" -e "s|{{SLUG}}|$SLUG|g" \
      -e "s|{{TITLE}}|$TITLE|g" -e "s|{{DATE}}|$DATE|g" -e "s|{{DIRNAME}}|$NAME|g" "$1"
}
for f in "$TPL"/*.md;          do subst "$f" > "$DIR/$(basename "$f")"; done
for f in "$TPL"/evidence/*.md; do subst "$f" > "$DIR/evidence/$(basename "$f")"; done
for f in "$DIAG"/*;            do subst "$f" > "$DIR/diagrams/$(basename "$f")"; done

echo "Created $DIR"
cat <<EOF

Next steps:
  1. bash $HERE/epic-children.sh $NUM        # inventory child tickets + Blocks links (read only)
  2. Fill 01-EPIC-AND-CONTEXT.md (R-list, AC, conflicts) BEFORE reading code.
EOF
