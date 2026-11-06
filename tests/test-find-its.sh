source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T"; R="$T/repo"
mkdir -p "$R/src/main/java/a" "$R/src/test/java/a"
echo 'class Foo {}' > "$R/src/main/java/a/Foo.java"
echo 'class Bar {}' > "$R/src/main/java/a/Bar.java"
echo 'class FooIT { Foo f; }' > "$R/src/test/java/a/FooIT.java"
echo 'class BarIT { Bar b; FooBar x; }' > "$R/src/test/java/a/BarIT.java"
git -C "$R" add -A && git -C "$R" commit -q -m base
base=$(git -C "$R" rev-parse HEAD)
echo 'class Foo { int x; }' > "$R/src/main/java/a/Foo.java"
git -C "$R" commit -q -am change
assert_eq "src/test/java/a/FooIT.java" "$(bash "$KF_S/find-its.sh" "$R" "$base")" "only the IT that references the changed class"
echo 'readme' > "$R/README.md"; git -C "$R" add README.md; git -C "$R" commit -q -m docs
base2=$(git -C "$R" rev-parse HEAD~1)
assert_eq "" "$(bash "$KF_S/find-its.sh" "$R" "$base2")" "no Java change, no IT"
# Uncommitted and untracked work counts (the builder may test before committing).
git -C "$R" checkout -q -- . 2>/dev/null
base3=$(git -C "$R" rev-parse HEAD)
echo 'class Bar { int y; }' > "$R/src/main/java/a/Bar.java"
assert_eq "src/test/java/a/BarIT.java" "$(bash "$KF_S/find-its.sh" "$R" "$base3")" "uncommitted change to Bar finds BarIT"
echo 'class Baz {}' > "$R/src/main/java/a/Baz.java"
echo 'class BazIT { Baz z; }' > "$R/src/test/java/a/BazIT.java"
assert_contains "src/test/java/a/BazIT.java" "$(bash "$KF_S/find-its.sh" "$R" "$base3")" "untracked class and IT are found"
assert_exit 1 "bad base ref fails" bash "$KF_S/find-its.sh" "$R" no-such-ref
assert_exit 1 "not a git repo fails" bash "$KF_S/find-its.sh" "$T" "$base3"
kf_finish
