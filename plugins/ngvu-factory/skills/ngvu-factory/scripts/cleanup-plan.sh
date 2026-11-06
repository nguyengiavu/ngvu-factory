#!/usr/bin/env bash
# Plan the clean-up of a finished ticket (read-only). Deleting worktrees, branches and files is a
# human action (core-governance), so this script only prints the plan and, with --write, writes a
# script the human reviews and runs. The written script uses only commands that refuse unsafe work:
# `git worktree remove` (no --force: refuses a dirty worktree), `git branch -d` (no -D: refuses an
# unmerged branch) and `rm` / `rm -r` (no -f) on the listed paths.
#
# Usage: cleanup-plan.sh <task folder> [--done] [--write <file>]   one ticket (git items need factory/ticket.json)
#        cleanup-plan.sh --all [--write <file>]                    every folder under paths.tasks: files only
# Items:
#   SECURITY  browser session files (Playwright storage state: JSON with "cookies"), any stage
#   DEPS      node_modules folders, any stage (re-created by `npm ci`)
#   TRACE     Playwright traces and videos (files named trace.zip, *.webm), only when done.
#             Downloads, screenshots, logs and playwright-report/ always stay.
#   WORKTREE  merged (or closed) ticket, worktree clean and nothing unpushed
#   BRANCH    local ticket branch whose work is merged (master, or the epic branch for a child)
#   KEEP      what stays, with the reason (traces kept: one line per folder)
# "Done" = ticket.json stage ready-for-pr/verified/closed and merge evidence, or stage closed;
# for a folder without ticket.json only --done, which the human asserts, makes it done.
# Exit: 0 plan has items, 24 nothing to clean, 3 folder not found, 1 usage.
set -uo pipefail
source "$(dirname "$0")/lib.sh"
S="$(dirname "$0")"

target=""; out=""; asserted=no
while [ $# -gt 0 ]; do
  case "$1" in
    --write) out="${2:-}"; [ -n "$out" ] || kf_die "--write needs a file"; shift 2 ;;
    --all) target="--all"; shift ;;
    --done) asserted=yes; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) [ -z "$target" ] || kf_die "one target only"; target="$1"; shift ;;
  esac
done
[ -n "$target" ] || kf_die "usage: cleanup-plan.sh <task folder> | --all [--write <file>]"

items=0; plan=""; cmds=""
q() { printf "'%s'" "${1//\'/\'\\\'\'}"; }
add() { # add <kind> <what> <reason> [command]
  plan+="$(printf '%-9s %s  (%s)' "$1" "$2" "$3")"$'\n'
  if [ -n "${4:-}" ]; then items=$((items+1)); cmds+="# $1: $3"$'\n'"$4"$'\n'; fi
}
size() { du -sh "$1" 2>/dev/null | cut -f1; }

scan_files() { # scan_files <folder> <done yes|no>
  local f="$1" done="$2" p
  while IFS= read -r -d '' p; do
    grep -q '"cookies"' "$p" 2>/dev/null && add SECURITY "$p" "browser session (Playwright storage state); also log out that session" "rm -- $(q "$p")"
  done < <(find "$f" -name node_modules -prune -o -type f -name '*.json' \( -name 'auth*.json' -o -name '*storage*state*.json' -o -path '*/.auth/*' \) -print0 2>/dev/null)
  while IFS= read -r -d '' p; do
    add DEPS "$p" "$(size "$p"), re-created by npm ci" "rm -r -- $(q "$p")"
  done < <(find "$f" -type d -name node_modules -prune -print0 2>/dev/null)
  local kept=() n
  while IFS= read -r -d '' p; do
    if [ "$done" = yes ]; then add TRACE "$p" "$(size "$p"), ticket done; downloads, screenshots, logs and reports stay" "rm -- $(q "$p")"
    else kept+=("$p"); fi
  done < <(find "$f" \( -name node_modules -o -name playwright-report \) -prune -o -type f \( -name 'trace.zip' -o -name '*.webm' \) -print0 2>/dev/null)
  n=${#kept[@]}
  [ "$n" -eq 0 ] || add KEEP "$f" "$n trace/video file(s), $(du -ch "${kept[@]}" 2>/dev/null | tail -n1 | cut -f1): ticket not done (or add --done)"
}

if [ "$target" = "--all" ]; then
  tasks="$(kf_cfg paths.tasks)" || exit 1
  [ -d "$tasks" ] || { echo "tasks dir not found: $tasks" >&2; exit 3; }
  for f in "$tasks"/*/; do scan_files "${f%/}" no; done
else
  F="${target%/}"
  [ -d "$F" ] || { echo "folder not found: $F" >&2; exit 3; }
  T="$F/factory/ticket.json"
  done=no
  if [ -f "$T" ]; then
    py="$(kf_python)" || exit 1
    # key, stage, epic, then one line per repo: name<TAB>worktree<TAB>branch<TAB>base
    mapfile -t meta < <("$py" -c '
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8-sig"))
print(d["key"]); print(d["stage"]); print(d.get("epic") or "")
for r in d["repos"]: print("\t".join([r["repo"], r["worktree"], r["branch"], r["base"]]))
' "$(kf_native_path "$T")" | tr -d '\r')
    key="${meta[0]}"; stage="${meta[1]}"
    finished=no; case "$stage" in ready-for-pr|verified|closed) finished=yes ;; esac
    merged_all=yes
    for line in "${meta[@]:3}"; do
      IFS=$'\t' read -r name wt branch base <<<"$line"
      repo="$(bash "$S/repo-path.sh" "$name" 2>/dev/null | head -n1 | cut -f1)"
      if [ -z "$repo" ]; then add KEEP "$name" "repo not found under paths.repoRoots"; merged_all=no; continue; fi
      merged=no
      if [[ "$base" == origin/master || "$base" == refs/remotes/origin/master ]]; then
        bash "$S/merged-to-master.sh" "$repo" "$key" >/dev/null 2>&1 && merged=yes
      else
        bash "$S/blocker-merged.sh" "$repo" "${base#origin/}" "$branch" >/dev/null 2>&1; rc=$?
        { [ $rc -eq 0 ] || [ $rc -eq 23 ]; } && merged=yes
      fi
      [ "$merged" = yes ] || merged_all=no
      removable=no; { [ "$finished" = yes ] && [ "$merged" = yes ]; } || [ "$stage" = closed ] && removable=yes
      if [ -d "$wt" ]; then
        dirty="$(git -C "$wt" status --porcelain 2>/dev/null | head -n1)"
        unpushed="$(git -C "$wt" log --oneline "refs/remotes/origin/$branch..HEAD" 2>/dev/null | head -n1)"
        git -C "$wt" rev-parse -q --verify "refs/remotes/origin/$branch" >/dev/null 2>&1 || unpushed="branch not on origin"
        if [ "$removable" = no ]; then add KEEP "$wt" "stage $stage, merged: $merged"
        elif [ -n "$dirty" ]; then add KEEP "$wt" "uncommitted changes"
        elif [ -n "$unpushed" ] && [ "$merged" = no ]; then add KEEP "$wt" "commits not on origin"
        else add WORKTREE "$wt" "$name: stage $stage, merged: $merged, clean" "git -C $(q "$repo") worktree remove $(q "$wt")"; fi
      fi
      if git -C "$repo" rev-parse -q --verify "refs/heads/$branch" >/dev/null 2>&1; then
        if [ "$merged" = yes ]; then add BRANCH "$name $branch" "merged; origin branch is left to GitHub" "git -C $(q "$repo") branch -d $(q "$branch")"
        else add KEEP "$name $branch" "branch not merged"; fi
      fi
    done
    { [ "$finished" = yes ] && [ "$merged_all" = yes ]; } || [ "$stage" = closed ] && done=yes
  else
    add KEEP "$F" "no factory/ticket.json: worktrees and branches unknown"
    done="$asserted"
  fi
  scan_files "$F" "$done"
fi

printf '%s' "$plan"
[ "$items" -gt 0 ] || { echo "nothing to clean"; exit 24; }
echo "$items item(s) to clean."
if [ -n "$out" ]; then
  { echo "#!/usr/bin/env bash"
    echo "# Clean-up written by cleanup-plan.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ). Review, then run it yourself."
    echo "# Every command refuses unsafe work on its own (no --force, no -D, no rm -f); errors are reported, not fatal."
    printf '%s' "$cmds" | sed '/^#/!s/$/ || echo "skipped (refused): see the line above"/'
  } > "$out"
  echo "written: $out"
fi
exit 0
