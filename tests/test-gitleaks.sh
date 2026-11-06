source "$(dirname "$0")/lib/assert.sh"
# Secret scan of this repo with gitleaks (default rules + .gitleaks.toml): working tree and history.
# gitleaks is optional on a member's machine: without it the check is skipped, except with
# KF_RELEASE=1 (the pre-publish gate), where a missing gitleaks fails.
cd "$KF_ROOT" || exit 1
if ! command -v gitleaks >/dev/null 2>&1; then
  if [ "${KF_RELEASE:-}" = 1 ]; then assert_eq installed missing "gitleaks is required for a release (winget install Gitleaks.Gitleaks)"
  else echo "  skip: gitleaks not installed (winget install Gitleaks.Gitleaks; KF_RELEASE=1 enforces)"; fi
  kf_finish; exit $?
fi
assert_exit 0 "no secret in the working tree" gitleaks dir --redact --no-banner .
assert_exit 0 "no secret in any commit" gitleaks git --redact --no-banner .
# the allowlist stays narrow: a planted credential is still found
a=Zx9-kq2L; b=mP4vT8wR  # assembled at run time so this file itself holds no secret-shaped text
T=$(kf_tmp); printf 'db:\n  password: "%s%s"\n' "$a" "$b" > "$T/leak.yml"
assert_exit 1 "a planted password is still detected" gitleaks dir --redact --no-banner --config .gitleaks.toml "$T"
kf_finish
