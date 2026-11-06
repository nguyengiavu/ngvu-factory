#!/usr/bin/env bash
# new-task.sh — create the standard investigation folder for a VUNG ticket.
#
# Folder convention (keep it so every ticket is looked up the same way):
#   <tasks>/VUNG-<number>-<slug-kebab>/   (<tasks> = paths.tasks of the factory config, see workspace.sh)
#
#   ./new-task.sh 100009 example-slug
#   ./new-task.sh 100009 example-slug --title "Block resubscription until the card is revalidated"
#
# The script only creates an empty skeleton with headings and required blanks.
# The content is the investigator's (person or agent) job. The skeleton exists so nobody
# forgets a section, and so every task folder reads the same.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$HERE/../templates"
source "$HERE/workspace.sh"

NUM=""; SLUG=""; TITLE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --root)  ROOT="$2"; TASKS="$ROOT/tasks"; shift 2 ;;
    --tasks) TASKS="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) if [ -z "$NUM" ]; then NUM="${1#VUNG-}"; NUM="${NUM#vung-}"; else SLUG="$1"; fi; shift ;;
  esac
done

[ -z "$NUM" ] || [ -z "$SLUG" ] && { echo "Usage: $0 <ticket-number> <slug-kebab> [--title '...']" >&2; exit 1; }

KEY="VUNG-$NUM"
DIR="$TASKS/$KEY-$SLUG"
DATE="$(date +%Y-%m-%d)"
[ -z "$TITLE" ] && TITLE="$KEY"

# One number = one folder: /ngvu-factory stops and asks when it sees two (VUNG-<n>-a, VUNG-<n>-b, EPIC-VUNG-<n>-…).
found=""
for p in "$TASKS/$KEY" "$TASKS/$KEY-"* "$TASKS/EPIC-$KEY" "$TASKS/EPIC-$KEY-"*; do
  [ -d "$p" ] && found="$found  $(basename "$p")"$'\n'
done
if [ -n "$found" ]; then
  echo "$KEY already has a folder:" >&2; printf '%s' "$found" >&2
  echo "Reopen that folder, or rename it first (the user decides). The script does not overwrite and does not create a second one." >&2
  exit 1
fi

[ -d "$TPL" ] || { echo "Templates not found at $TPL" >&2; exit 1; }

mkdir -p "$DIR/diagrams"

subst() {
  sed -e "s|{{TICKET}}|$KEY|g" \
      -e "s|{{NUM}}|$NUM|g" \
      -e "s|{{SLUG}}|$SLUG|g" \
      -e "s|{{TITLE}}|$TITLE|g" \
      -e "s|{{DATE}}|$DATE|g" \
      -e "s|{{DIRNAME}}|$KEY-$SLUG|g" "$1"
}

for f in "$TPL"/*.md; do
  [ -e "$f" ] || continue
  subst "$f" > "$DIR/$(basename "$f")"
done
for f in "$TPL"/diagrams/*; do
  [ -e "$f" ] || continue
  subst "$f" > "$DIR/diagrams/$(basename "$f")"
done

echo "Created $DIR"
echo
find "$DIR" -type f | sort | sed "s|$DIR|  .|"
echo
cat <<EOF
Next steps:
  1. Read the ticket + epic in Jira, fill in 01-TICKET-AND-CONTEXT.md FIRST.
     If the Acceptance Criteria are empty or contradict a sibling ticket -> stop, ask the PO.
  2. bash $HERE/scan-ticket-refs.sh $NUM   # find which repo/branch already has code
  3. bash $HERE/branch-status.sh <repo-path> <branch>  # find the right base branch before coding
EOF
