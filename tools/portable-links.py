"""Make skill text work wherever the skill is installed (user level or any plugin).

Rewrites, in every *.md under plugins/*/skills/<skill>/ and plugins/*/rules/:
  [t](../../rules/X.md), ../../rules/X.md      -> ~/.claude/rules/X.md (installed by deploy/bootstrap)
  [t](../<s>/SKILL.md), ../skills/<s>/SKILL.md  -> t (skill `<s>`)      (skills load by name)
  [t](../PROJECT-STACK.md)                       -> t (skill `ngvu-project-stack`)
  ~/.claude/skills/<this skill>/  in SKILL.md    -> ${CLAUDE_SKILL_DIR}/
  ~/.claude/skills/<this skill>/  elsewhere      -> <skill dir>/
  ~/.claude/skills/<other>/<path>                -> `<path>` of skill `<other>`
Leaves ~/.claude/skills/_context (a user state file) alone.
Usage: portable-links.py check|write <repo root>
Exit: 0 clean (check) or written, 1 check found links to rewrite, 2 usage.
"""
import os
import re
import sys

RULES_LINK = re.compile(r"\]\((?:\.\./)+rules/([A-Za-z0-9_-]+\.md)\)")
RULES_BARE = re.compile(r"(?<![\w/~])(?:\.\./)+rules/([A-Za-z0-9_-]+\.md)")
SKILL_LINK = re.compile(r"\[([^\]\n]*)\]\((?:\.\./)+(?:skills/)?([a-z0-9-]+)/SKILL\.md\)")
SKILL_BARE = re.compile(r"(?<![\w/~])(?:\.\./)+(?:skills/)?([a-z0-9-]+)/SKILL\.md")
STACK_LINK = re.compile(r"\[([^\]\n]*)\]\((?:\.\./)+(?:skills/)?PROJECT-STACK\.md\)")
STACK_BARE = re.compile(r"(?<![\w/~])(?:\.\./)+(?:skills/)?PROJECT-STACK\.md")
HOME_SKILL = re.compile(r"(?:~|\$HOME|\$\{HOME\})/\.claude/skills/([A-Za-z0-9_-]+)/([^\s`\"')\]]*)")


def named(text, name):
    t = text.strip().strip("`")
    if t == name or "/" in t or t.endswith(".md"):  # link text is the name or the old path
        return "the `%s` skill" % name
    return "%s (skill `%s`)" % (text, name)


def rewrite(text, skill, is_skill_md):
    text = RULES_LINK.sub(r"](~/.claude/rules/\1)", text)
    text = RULES_BARE.sub(r"~/.claude/rules/\1", text)
    text = STACK_LINK.sub(lambda m: named(m.group(1), "ngvu-project-stack"), text)
    text = STACK_BARE.sub("the `ngvu-project-stack` skill", text)
    text = SKILL_LINK.sub(lambda m: named(m.group(1), m.group(2)), text)
    text = SKILL_BARE.sub(lambda m: "the `%s` skill" % m.group(1), text)

    def home(m):
        s, rest = m.group(1), m.group(2)
        if s == "_context":
            return m.group(0)
        tail = rest[len(rest.rstrip(".,;:")):]
        rest = rest[:len(rest) - len(tail)]
        if s == skill:
            return ("${CLAUDE_SKILL_DIR}/" if is_skill_md else "<skill dir>/") + rest + tail
        return ("`%s` of skill `%s`" % (rest, s) if rest else "skill `%s`" % s) + tail
    text = HOME_SKILL.sub(home, text)
    return re.sub(r"(`[a-z0-9-]+` skill) skill\b", r"\1", text)  # "[`x`](..) skill" was already a noun


def files(root):
    for plugin in sorted(os.listdir(os.path.join(root, "plugins"))):
        rules = os.path.join(root, "plugins", plugin, "rules")  # installed to ~/.claude/rules
        if os.path.isdir(rules):
            for f in sorted(os.listdir(rules)):
                if f.endswith(".md"):
                    yield os.path.join(rules, f), "", False
        sk = os.path.join(root, "plugins", plugin, "skills")
        if not os.path.isdir(sk):
            continue
        for skill in sorted(os.listdir(sk)):
            d = os.path.join(sk, skill)
            if not os.path.isdir(d):
                continue
            for dp, _, fs in os.walk(d):
                for f in fs:
                    if f.endswith(".md"):
                        p = os.path.join(dp, f)
                        yield p, skill, os.path.normpath(p) == os.path.normpath(os.path.join(d, "SKILL.md"))


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("check", "write"):
        print(__doc__.strip().splitlines()[-3], file=sys.stderr)
        sys.exit(2)
    mode, root = sys.argv[1], sys.argv[2]
    dirty = []
    for p, skill, is_skill_md in files(root):
        old = open(p, encoding="utf-8").read()
        new = rewrite(old, skill, is_skill_md)
        if new != old:
            dirty.append(os.path.relpath(p, root))
            if mode == "write":
                with open(p, "w", encoding="utf-8", newline="") as f:
                    f.write(new)
    for d in dirty:
        print(("rewrote " if mode == "write" else "non-portable: ") + d.replace("\\", "/"))
    sys.exit(1 if dirty and mode == "check" else 0)


if __name__ == "__main__":
    main()
