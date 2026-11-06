source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"
source "$KF_S/lib.sh"
assert_eq "ngvu/" "$(kf_cfg branchPrefix)" "kf_cfg reads a scalar"
assert_eq "ngvu" "$(kf_cfg ownTeams)" "kf_cfg reads a list"
assert_eq "2" "$(kf_cfg maxResumes)" "kf_cfg reads a number"
assert_eq "$T/tasks" "$(kf_cfg paths.tasks)" "kf_cfg reads a nested key"
assert_exit 3 "kf_cfg fails on a missing key" kf_cfg no.such.key
unset KF_CONFIG
assert_eq "ngvu/" "$(kf_cfg branchPrefix)" "falls back to repo config/factory.config.json"
# A config saved with a UTF-8 BOM (PowerShell 5.1 Set-Content -Encoding utf8) must still load.
mkdir -p "$T/bom" && printf '\357\273\277' > "$T/bom/factory.config.json" && cat "$KF_ROOT/plugins/ngvu-factory/skills/ngvu-factory/factory.config.json" >> "$T/bom/factory.config.json"
assert_eq "ngvu/" "$(KF_CONFIG="$T/bom/factory.config.json" kf_cfg branchPrefix)" "config with BOM loads"
# Machine overlay: merged over the bundled config, survives plugin updates.
printf '{"paths": {"tasks": "E:/Work/workspace/tasks"}, "ownTeams": ["optimus"]}' > "$T/machine.json"
assert_eq "E:/Work/workspace/tasks" "$(KF_MACHINE_CONFIG="$T/machine.json" kf_cfg paths.tasks)" "overlay replaces a nested key"
assert_eq "D:/workspace/.ngvu-worktrees" "$(KF_MACHINE_CONFIG="$T/machine.json" kf_cfg paths.worktrees)" "overlay keeps sibling keys"
assert_eq "optimus" "$(KF_MACHINE_CONFIG="$T/machine.json" kf_cfg ownTeams)" "overlay replaces a list"
assert_eq "ngvu/" "$(KF_MACHINE_CONFIG="$T/machine.json" kf_cfg branchPrefix)" "overlay keeps untouched keys"
echo '{broken' > "$T/bad.json"
assert_exit 1 "invalid overlay stops instead of using defaults" env KF_MACHINE_CONFIG="$T/bad.json" bash -c "source '$KF_S/lib.sh'; kf_config_path"
kf_finish
