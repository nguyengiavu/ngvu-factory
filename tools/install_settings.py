"""Register the ngvu-factory guardrails in <claude-home>/settings.json.

Adds, without touching anything else:
  - a PreToolUse hook (matcher Bash|PowerShell) running <claude-home>/hooks/ngvu_guardrails.py
    (with --no-hook, the plugin install: the core-governance plugin ships that hook itself, so a
    user-level hook naming ngvu_guardrails.py, left by install.sh, is removed instead; otherwise
    every Bash/PowerShell call would be checked by two copies that can disagree)
  - permissions.deny entries for the Atlassian MCP write tools
  - with --skill-overrides <file>: each skillOverrides entry of that JSON file the settings lack
    (an entry already set by the user is kept)
Idempotent: an existing hook command naming ngvu_guardrails.py counts as registered.
Usage: install_settings.py <claude-home> [--dry-run] [--no-hook] [--skill-overrides <file>]
Prints one line per planned change. Exit: 0 ok, 1 usage or unreadable settings.json.
"""
import json
import os
import shutil
import sys

HOOK_FILE = "ngvu_guardrails.py"
MCP = "mcp__claude_ai_Atlassian__"  # shortcut: matches the claude.ai connector name only; add the prefix of any other Atlassian MCP you connect
DENY = [MCP + t for t in (
    "addCommentToJiraIssue", "addWorklogToJiraIssue", "createIssueLink", "createJiraIssue",
    "editJiraIssue", "transitionJiraIssue", "createConfluencePage", "updateConfluencePage",
    "createConfluenceFooterComment", "createConfluenceInlineComment", "createCompassComponent",
    "createCompassComponentRelationship", "createCompassCustomFieldDefinition")]


def plan(settings, home, hook=True, overrides=None):
    changes = []
    pre = settings.get("hooks", {}).get("PreToolUse", [])
    registered = any(HOOK_FILE in h.get("command", "") for e in pre for h in e.get("hooks", []))
    if hook and not registered:
        cmd = 'python "%s"' % os.path.join(home, "hooks", HOOK_FILE).replace("\\", "/")
        changes.append(("hook", {"matcher": "Bash|PowerShell", "hooks": [{"type": "command", "command": cmd}]}))
    if not hook:
        changes += [("unhook", h["command"]) for e in pre for h in e.get("hooks", [])
                    if HOOK_FILE in h.get("command", "")]
    have = set(settings.get("permissions", {}).get("deny", []))
    changes += [("deny", d) for d in DENY if d not in have]
    current = settings.get("skillOverrides", {})
    changes += [("override", (k, v)) for k, v in (overrides or {}).items() if k not in current]
    return changes


def describe(kind, value):
    if kind == "hook":
        return "hook     " + value["hooks"][0]["command"]
    if kind == "unhook":
        return "unhook   " + value + " (the core-governance plugin ships this guard)"
    if kind == "deny":
        return "deny     " + value
    return "override %s=%s" % value


def main():
    argv = sys.argv[1:]
    dry = "--dry-run" in argv
    hook = "--no-hook" not in argv
    overrides = None
    if "--skill-overrides" in argv:
        i = argv.index("--skill-overrides")
        if i + 1 >= len(argv):
            print("--skill-overrides needs a file", file=sys.stderr)
            sys.exit(1)
        try:
            overrides = json.load(open(argv[i + 1], encoding="utf-8-sig"))["skillOverrides"]
        except (OSError, ValueError, KeyError) as e:
            print("cannot read skillOverrides from %s: %s" % (argv[i + 1], e), file=sys.stderr)
            sys.exit(1)
        del argv[i:i + 2]
    args = [a for a in argv if a not in ("--dry-run", "--no-hook")]
    if len(args) != 1:
        print("usage: install_settings.py <claude-home> [--dry-run] [--no-hook] [--skill-overrides <file>]", file=sys.stderr)
        sys.exit(1)
    home = os.path.abspath(args[0])
    path = os.path.join(home, "settings.json")
    settings = {}
    if os.path.exists(path):
        try:
            settings = json.load(open(path, encoding="utf-8-sig"))
        except ValueError as e:
            print("settings.json is not valid JSON, left untouched: %s" % e, file=sys.stderr)
            sys.exit(1)
    changes = plan(settings, home, hook, overrides)
    for kind, value in changes:
        print("  settings %s" % describe(kind, value))
    if not changes or dry:
        sys.exit(0)
    if os.path.exists(path):
        shutil.copyfile(path, path + ".bak-ngvu-factory")
    for kind, value in changes:
        if kind == "hook":
            settings.setdefault("hooks", {}).setdefault("PreToolUse", []).append(value)
        elif kind == "unhook":
            pre = settings["hooks"]["PreToolUse"]
            for e in pre:
                e["hooks"] = [h for h in e.get("hooks", []) if h.get("command") != value]
            settings["hooks"]["PreToolUse"] = [e for e in pre if e.get("hooks")]
        elif kind == "deny":
            settings.setdefault("permissions", {}).setdefault("deny", []).append(value)
        else:
            settings.setdefault("skillOverrides", {})[value[0]] = value[1]
    os.makedirs(home, exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")


if __name__ == "__main__":
    main()
