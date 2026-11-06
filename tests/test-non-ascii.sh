source "$(dirname "$0")/lib/assert.sh"
T=$(kf_tmp); kf_test_config "$T"; kf_git_fixture "$T"; R="$T/repo"
base=$(git -C "$R" rev-parse HEAD)
mkdir -p "$R/src" "$R/locales"
printf 'class A {\n  // check the card\n}\n' > "$R/src/A.java"
printf 'title: "Ki\xe1\xbb\x83m tra"\n' > "$R/locales/vi.yaml"
git -C "$R" add -A && git -C "$R" commit -q -m ascii
assert_exit 0 "ASCII code and translation files pass" bash "$KF_S/non-ascii-check.sh" "$R" "$base"
printf 'class B {\n  // ki\xe1\xbb\x83m tra th\xe1\xba\xbb\n}\n' > "$R/src/B.java"
git -C "$R" add -A && git -C "$R" commit -q -m vi
out=$(bash "$KF_S/non-ascii-check.sh" "$R" "$base"); rc=$?
assert_eq 13 "$rc" "non-ASCII comment found"
assert_contains "B.java" "$out" "names the file"
# Uncommitted and untracked work counts.
base2=$(git -C "$R" rev-parse HEAD)
printf 'class A {\n  // ki\xe1\xbb\x83m\n}\n' > "$R/src/A.java"
out=$(bash "$KF_S/non-ascii-check.sh" "$R" "$base2"); rc=$?
assert_eq 13 "$rc" "uncommitted non-ASCII comment found"
git -C "$R" checkout -q -- src/A.java
printf 'class C {\n  // th\xe1\xba\xbb\n}\n' > "$R/src/C.java"
out=$(bash "$KF_S/non-ascii-check.sh" "$R" "$base2"); rc=$?
assert_eq 13 "$rc" "untracked file with non-ASCII comment found"
assert_contains "src/C.java" "$out" "names the untracked file"
rm "$R/src/C.java"
printf 'export const A = () => null; // th\xe1\xba\xbb\n' > "$R/src/A.tsx"
out=$(bash "$KF_S/non-ascii-check.sh" "$R" "$base2"); rc=$?
assert_eq 13 "$rc" "non-ASCII comment in a .tsx file found"
assert_contains "src/A.tsx" "$out" "names the .tsx file"
rm "$R/src/A.tsx"
assert_exit 1 "bad base ref fails" bash "$KF_S/non-ascii-check.sh" "$R" no-such-ref
kf_finish
