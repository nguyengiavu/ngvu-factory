#!/usr/bin/env bash
# new-child.sh — scaffold the investigation folder for ONE child ticket of an epic, at the tasks/ level (next to the epic).
#
#   bash new-child.sh <epic-number> <child-ticket-number> <kebab-slug> [--title "..."] [--root <workspace>]
#
# Result: <tasks>/VUNG-<child>-<slug>/ (the 01..08 frame of ngvu-ticket-investigation), README pointing back to
# the epic folder. Placed at the tasks/ level so /ngvu-factory (resolve-task-folder.sh) finds the child ticket.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_TASK="$HERE/../../ngvu-ticket-investigation/scripts/new-task.sh"
source "$HERE/../../ngvu-ticket-investigation/scripts/workspace.sh"

args=(); E=""; N=""; SLUG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root)  ROOT="$2"; TASKS="$ROOT/tasks"; shift 2 ;;
    --title) args+=(--title "$2"); shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) v="${1#VUNG-}"; v="${v#vung-}"
       if [ -z "$E" ]; then E="$v"; elif [ -z "$N" ]; then N="$v"; else SLUG="$1"; fi; shift ;;
  esac
done
{ [[ "$E" =~ ^[0-9]+$ ]] && [[ "$N" =~ ^[0-9]+$ ]] && [ -n "$SLUG" ]; } \
  || { echo "Usage: $0 <epic-number> <child-ticket-number> <kebab-slug> [--title '...']" >&2; exit 1; }

dirs() { local p; for p in "$@"; do [ -d "$p" ] && printf '%s\n' "$p"; done; return 0; }
mapfile -t epics < <(dirs "$TASKS/EPIC-VUNG-$E" "$TASKS/EPIC-VUNG-$E-"*)
mapfile -t kids  < <(dirs "$TASKS/VUNG-$N" "$TASKS/VUNG-$N-"* "$TASKS/EPIC-VUNG-$N" "$TASKS/EPIC-VUNG-$N-"*)
[ "${#epics[@]}" -eq 1 ] || { echo "Need exactly one EPIC-VUNG-$E* folder, found ${#epics[@]}: ${epics[*]:-}" >&2; exit 1; }
[ "${#kids[@]}" -eq 0 ] || { echo "VUNG-$N already has a folder: ${kids[*]}" >&2; exit 1; }
EPIC_DIR="$(basename "${epics[0]}")"

bash "$NEW_TASK" "$N" "$SLUG" --tasks "$TASKS" "${args[@]}" >/dev/null
CHILD="$TASKS/VUNG-$N-$SLUG"
link="[VUNG-$E](https://example.atlassian.net/browse/VUNG-$E) · epic folder: [$EPIC_DIR](../$EPIC_DIR/README.md)"
sed -i "s#^> \*\*Epic\*\*:.*#> **Epic**: $link#" "$CHILD/README.md"

echo "Created $CHILD"
cat <<EOF

Next:
  1. Fill the VUNG-$N row in the '## Factory queue' table (Jira column) in ../$EPIC_DIR/08-STORY-BREAKDOWN.md,
     then run breakdown.sh again.
  2. Investigate the child ticket with the ngvu-ticket-investigation skill; the child's 01 points to ../$EPIC_DIR/01-EPIC-AND-CONTEXT.md
     instead of copying the epic context.
EOF
