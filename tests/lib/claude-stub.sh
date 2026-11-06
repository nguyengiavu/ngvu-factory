#!/usr/bin/env bash
# Fake `claude` CLI for deploy tests. State lives in $STUB_STATE (marketplaces, plugins, calls).
# The real CLI prints "  ❯ <name>" lines for marketplace list and plugin list.
s="${STUB_STATE:?}"; touch "$s/marketplaces" "$s/plugins"
echo "$*" >> "$s/calls"
case "$*" in
  --version) echo "${STUB_VERSION:-2.1.312} (Claude Code)" ;;
  "plugin marketplace list") echo "Configured marketplaces:"; sed 's/^/  ❯ /' "$s/marketplaces" ;;
  "plugin marketplace add "*) echo ngvu-ai-factory >> "$s/marketplaces" ;;
  "plugin marketplace update "*) ;;
  "plugin marketplace remove "*) sed -i "/^$4\$/d" "$s/marketplaces" ;;
  "plugin list") echo "Installed plugins:"; sed 's/^/  ❯ /' "$s/plugins" ;;
  "plugin install "*) echo "$3" >> "$s/plugins" ;;
  "plugin update "*) ;;
  "plugin uninstall "*) sed -i "/^$3\$/d" "$s/plugins" ;;
  *) echo "stub: unexpected: $*" >&2; exit 9 ;;
esac
