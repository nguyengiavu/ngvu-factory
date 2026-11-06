#!/usr/bin/env bash
# branch-status.sh — is this branch merged into master yet, and what does it change?
#
# Why: in ngvu, an epic's code often lives for months on the epic branch before it
# reaches master. Base a new branch on the wrong parent and you lose half a day on
# conflicts, and worse, you analyse old code. Always run this before creating a branch.
#
#   ./branch-status.sh <workspace>/services/example_core <team>/vung-100010/EPIC-individual-credit-card-only
#   ./branch-status.sh <workspace>/services/example_core <branch> --fetch    # fetch before comparing
#   ./branch-status.sh <workspace>/services/example_core <branch> --files    # list every changed file

set -uo pipefail

REPO="${1:-}"; BRANCH="${2:-}"; shift 2 2>/dev/null || true
DO_FETCH=0; SHOW_ALL_FILES=0
for a in "$@"; do
  case "$a" in
    --fetch) DO_FETCH=1 ;;
    --files) SHOW_ALL_FILES=1 ;;
  esac
done

[ -z "$REPO" ] || [ -z "$BRANCH" ] && { sed -n '2,12p' "$0"; exit 1; }
[ -d "$REPO/.git" ] || { echo "Not a git repo: $REPO" >&2; exit 1; }
cd "$REPO" || exit 1

BASE="${BASE_BRANCH:-master}"
git show-ref --verify -q "refs/heads/$BASE" || BASE=main

REF="$BRANCH"
git rev-parse --verify -q "$REF" >/dev/null || REF="origin/$BRANCH"

if [ "$DO_FETCH" = 1 ]; then
  echo "== Fetch $BRANCH =="
  timeout 120 git fetch origin "$BRANCH:refs/remotes/origin/$BRANCH" 2>&1 | tail -3
  REF="origin/$BRANCH"
fi

git rev-parse --verify -q "$REF" >/dev/null || {
  echo "Ref '$BRANCH' not found (try adding --fetch)." >&2; exit 1; }

echo "== $(basename "$REPO") :: $REF  (compared with $BASE) =="
echo

echo "--- Merged into $BASE? ---"
if git merge-base --is-ancestor "$REF" "$BASE" 2>/dev/null; then
  echo "    MERGED — basing a new branch on $BASE is safe."
else
  AHEAD=$(git rev-list --count "$BASE..$REF" 2>/dev/null)
  BEHIND=$(git rev-list --count "$REF..$BASE" 2>/dev/null)
  echo "    NOT MERGED — branch is $AHEAD commits ahead of and $BEHIND commits behind $BASE."
  echo "    => Base the new branch on '$REF', NOT on $BASE."
fi

echo
echo "--- Which branches contain the first commit of this branch? ---"
FIRST=$(git rev-list "$BASE..$REF" 2>/dev/null | tail -1)
[ -n "$FIRST" ] && git branch -a --contains "$FIRST" 2>/dev/null | head -8 | sed 's/^/    /'

echo
echo "--- Commits (newest first) ---"
git log --oneline "$BASE..$REF" 2>/dev/null | head -25 | sed 's/^/    /'

echo
echo "--- Changed files ---"
if [ "$SHOW_ALL_FILES" = 1 ]; then
  git diff --stat "$BASE...$REF" 2>/dev/null | sed 's/^/    /'
else
  git diff --stat "$BASE...$REF" 2>/dev/null | tail -30 | sed 's/^/    /'
  echo "    (use --files to see all)"
fi

echo
echo "--- DB migrations in this branch (sign of a schema change) ---"
git diff --name-only "$BASE...$REF" 2>/dev/null \
  | grep -iE "db/(migration|public)/|liquibase|\.sql$" | sed 's/^/    /' \
  || echo "    (none)"
