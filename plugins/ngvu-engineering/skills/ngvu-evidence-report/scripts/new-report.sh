#!/usr/bin/env bash
# Scaffold an evidence-backed deliverable.
#   new-report.sh <kind> <slug> --title "<title>" [--into <parent-folder>]
#   kind = incident | qa | onepager
# Refuses to overwrite an existing folder.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$SKILL_DIR/assets/report-template.html"
# Workspace: NGVU_WORKSPACE, else "workspace" in the machine config written by deploy/bootstrap, else D:/workspace.
ws="$(sed -n 's/^ *"workspace": *"\([^"]*\)".*/\1/p' "${KF_MACHINE_CONFIG:-$HOME/.claude/ngvu-factory/machine.json}" 2>/dev/null | head -n1 || true)"
DEFAULT_ROOT="${NGVU_WORKSPACE:-${ws:-D:/workspace}}/reports"

die() { printf 'Error: %s\n' "$1" >&2; exit 1; }

[ $# -ge 2 ] || die "Usage: new-report.sh <incident|qa|onepager> <slug> --title \"<title>\" [--into <folder>]"

KIND="$1"; SLUG="$2"; shift 2
TITLE=""; INTO=""

while [ $# -gt 0 ]; do
  case "$1" in
    --title) [ $# -ge 2 ] || die "--title needs a value"; TITLE="$2"; shift 2 ;;
    --into)  [ $# -ge 2 ] || die "--into needs a value";  INTO="$2";  shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

case "$KIND" in
  incident|qa|onepager) ;;
  *) die "kind must be incident, qa or onepager (got: $KIND)" ;;
esac

printf '%s' "$SLUG" | grep -Eq '^[a-z0-9][a-z0-9-]*$' \
  || die "slug may only contain lowercase letters, digits and hyphens (got: $SLUG)"

[ -f "$TEMPLATE" ] || die "Template not found: $TEMPLATE"
[ -n "$TITLE" ] || TITLE="$SLUG"

DATE="$(date -u +%Y-%m-%d)"
PARENT="${INTO:-$DEFAULT_ROOT}"
DIR="$PARENT/$DATE-$KIND-$SLUG"

[ -e "$DIR" ] && die "Folder already exists, not overwriting: $DIR"

mkdir -p "$DIR"

# Put the title into <title> and <h1>. ENVIRON + substr keep "&" and "\" in the title literal (gsub and -v would not).
T="$TITLE" awk 'BEGIN { t = ENVIRON["T"] }
  { s = $0; out = ""
    while (match(s, /__TITLE(: [^_]*)?__/)) { out = out substr(s, 1, RSTART - 1) t; s = substr(s, RSTART + RLENGTH) }
    print out s }' "$TEMPLATE" > "$DIR/report.html"

cat > "$DIR/NOTES.md" <<EOF
# $TITLE

Kind: $KIND · Created: $DATE (UTC)

> Write RAW evidence here while you work, with its source on the spot.
> Recalling the source after writing is where errors creep in.

## The question this document answers

<one single sentence>

## Reader

<external stakeholder | PO/tech lead | engineer in the team> — sets the technical depth

## Evidence collected

| Fact | Source | Confidence |
|---|---|---|
|  | \`repo/File.java:123\` / VUNG-xxxxx / log link |  |

## Rejected hypotheses

<hypothesis + the evidence that rejects it — do not leave this empty if there is one>

## What is NOT proven yet

<gaps in your own evidence>

## Left to do before handoff

- [ ] Run the QA gate: references/qa-gate.md
- [ ] Anonymise identifiers, run secret-data-guard
- [ ] Click every Cloud Logging link
- [ ] Ask the user before publishing
EOF

printf 'Created:\n  %s/report.html\n  %s/NOTES.md\n\n' "$DIR" "$DIR"
printf 'Next step: read references/quality-bar.md before writing.\n'
