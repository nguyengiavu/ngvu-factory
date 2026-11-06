#!/usr/bin/env bash
# Report non-ASCII characters in added code lines (comments must be English: NGVU-CONTEXT.md).
# Covers committed work since the merge-base, uncommitted changes and untracked files.
# Translation files (messages/, locales/) are user-facing strings and are excluded.
# Usage: non-ascii-check.sh <worktree> <base-ref>
# Prints "<file>: <line>" per hit. Exit: 0 none, 13 found, 1 usage, bad base ref or git failure.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

wt="${1:-}"; base="${2:-}"
[ -n "$base" ] || kf_die "usage: non-ascii-check.sh <worktree> <base-ref>"
mb=$(git -C "$wt" merge-base "$base" HEAD 2>/dev/null) || kf_die "cannot resolve base '$base' in $wt"
specs=('*.java' '*.js' '*.jsx' '*.ts' '*.tsx' '*.sql' '*.properties' '*.xml' '*.yaml' '*.yml' ':(glob,exclude)**/messages/**' ':(glob,exclude)**/locales/**')

diff=$(git -C "$wt" diff -U0 "$mb" -- "${specs[@]}") || kf_die "git diff failed in $wt"
hits=$(printf '%s\n' "$diff" | LC_ALL=C awk '
  /^\+\+\+ / { file = substr($0, 7); next }
  /^\+/ && /[\200-\377]/ { print file ": " substr($0, 2) }')

untracked=$(git -C "$wt" ls-files --others --exclude-standard -- "${specs[@]}") || kf_die "git ls-files failed in $wt"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  more=$(LC_ALL=C awk -v f="$f" '/[\200-\377]/ { print f ": " $0 }' "$wt/$f")
  [ -n "$more" ] && hits=$(printf '%s\n%s' "$hits" "$more")
done <<< "$untracked"

hits=$(printf '%s\n' "$hits" | sed '/^$/d')
[ -z "$hits" ] && exit 0
printf '%s\n' "$hits"
exit 13
