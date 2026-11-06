# Minimal assertion helpers for ngvu-factory tests. Source it.
set -uo pipefail
KF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KF_S="$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/scripts"
KF_PASS=0; KF_FAIL=0
# Never read this machine's overlay (~/.claude/ngvu-factory/machine.json) in tests.
export KF_MACHINE_CONFIG="${TMPDIR:-/tmp}/kf-test-no-machine-config.json"
export GIT_AUTHOR_NAME=kf-test GIT_AUTHOR_EMAIL=kf-test@example.invalid
export GIT_COMMITTER_NAME=kf-test GIT_COMMITTER_EMAIL=kf-test@example.invalid

_kf_fail() { local l; KF_FAIL=$((KF_FAIL+1)); printf 'FAIL: %s\n' "$1"; shift; for l in "$@"; do printf '  %s\n' "$l"; done; return 0; }
assert_eq() { if [ "$1" == "$2" ]; then KF_PASS=$((KF_PASS+1)); else _kf_fail "$3" "expected: [$1]" "actual:   [$2]"; fi; }
assert_contains() { case "$2" in *"$1"*) KF_PASS=$((KF_PASS+1)) ;; *) _kf_fail "$3" "missing: [$1]" "in: [$2]" ;; esac; }
assert_not_contains() { case "$2" in *"$1"*) _kf_fail "$3" "unexpected: [$1]" ;; *) KF_PASS=$((KF_PASS+1)) ;; esac; }
# assert_exit <expected-code> <message> <cmd> [args...]
assert_exit() { local exp=$1 msg=$2; shift 2; "$@" >/dev/null 2>&1; assert_eq "$exp" "$?" "$msg (exit code)"; }
kf_tmp() { mktemp -d "${TMPDIR:-/tmp}/kf-test.XXXXXX"; }

# kf_test_config <dir> [tasks-dir]: write a config into <dir> and export KF_CONFIG.
kf_test_config() {
  local d=$1 tasks=${2:-$1/tasks}
  mkdir -p "$tasks"
  cat > "$d/factory.config.json" <<EOF
{ "team": "ngvu", "branchPrefix": "ngvu/",
  "ownTeams": ["ngvu"], "legacyOwnerAliases": { "team-a": "ngvu" },
  "maxResumes": 2,
  "paths": { "repoRoots": [{"path": "$d/services", "kind": "java-service"}, {"path": "$d/nextjs", "kind": "nextjs"}], "tasks": "$tasks",
             "worktrees": "$d/wt", "unitTestScript": "D:/workspace/scripts/mvn-unit.bat" },
  "jira": { "site": "example.atlassian.net", "project": "VUNG" } }
EOF
  export KF_CONFIG="$d/factory.config.json"
}

# kf_git_fixture <dir>: bare origin at <dir>/origin.git, clone at <dir>/repo, one commit on master pushed.
kf_git_fixture() {
  local d=$1
  git init -q --bare "$d/origin.git"
  git -C "$d/origin.git" symbolic-ref HEAD refs/heads/master
  git clone -q "$d/origin.git" "$d/repo" 2>/dev/null
  git -C "$d/repo" config core.autocrlf false
  git -C "$d/repo" checkout -q -B master
  git -C "$d/repo" commit -q --allow-empty -m init
  git -C "$d/repo" push -q origin master 2>/dev/null
}

kf_finish() { echo "$(basename "$0"): passed=$KF_PASS failed=$KF_FAIL"; [ "$KF_FAIL" -eq 0 ]; }
