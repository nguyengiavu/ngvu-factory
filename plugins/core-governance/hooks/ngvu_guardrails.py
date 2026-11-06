"""PreToolUse guardrail for Bash and PowerShell tool calls.

Blocks (exit 2, reason on stderr):
  - git push in any form (git -C <repo> push, rtk git push, bash -c "git push", ...), except
    `git [-C <repo>] push [-u|-q|-v|--dry-run] origin <branch>` where <branch> names a VUNG ticket
    or epic branch (contains vung-<n>) and no path segment is master/main/develop/release.
    No refspec (a:b, +a, HEAD), no force/--all/--mirror/--tags/--delete/--no-verify.
    Under a personal root (machine config `personalRoots`, e.g. ["D:/Personal"]; empty by default),
    when the hook cwd and every -C / cd target lie there, any non-protected branch may be pushed.
    Merging into master happens only through a reviewed GitHub PR, by a human.
  - a git alias that runs push (git -c alias.p=push p, git config alias.p push)
  - destructive git: reset --hard, clean -f, branch -D / --delete --force,
    checkout . / restore . (not restore --staged), checkout -f, switch -f / --discard-changes,
    stash clear / drop, update-ref -d, worktree remove --force
  - Atlassian CLI (acli) write commands: create, edit, transition, delete, assign, ...
    also when acli is reached through a path, a variable ("$ACLI", & $acli) or $(...) / (...)

Reads the hook JSON on stdin. Unparseable input is blocked only if it mentions git push.
Self-test: python ngvu_guardrails.py --self-test
"""
import json
import os
import re
import shlex
import sys

SEPARATORS = re.compile(r"\|\||&&|\$\(|[;|\n&`)]")
HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
GIT_MESSAGE_CMD = re.compile(r"^\s*(\S+\s+)*?(\S*[\\/])?git(\.exe)?\b.*\b(commit|tag|notes)\b")
MESSAGE_ARG = re.compile(r"(?<!\S)(-[A-Za-z]*m|--message)(=|\s+)(\"(?:[^\"\\]|\\.)*\"|'[^']*')")
SUBST = re.compile(r"\$\(([^()]*)\)|`([^`]*)`")
GIT_OPTS_WITH_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path", "--super-prefix"}
ALIAS_PUSH = re.compile(r"^alias\.[^=\s]+(=|\s|$).*\bpush\b", re.I)
ACLI_WRITE = {"create", "edit", "update", "transition", "delete", "remove", "assign", "move",
              "archive", "unarchive", "link", "clone", "attach", "import"}
# What can stand for acli: a $(...), (...)[.Prop] or `...` group, NAME=... / $name = ..., $var.
ACLI_GROUP = re.compile(r"\$?\([^()]*\)(?:\.\w+)*|`[^`]*`")
ASSIGN = re.compile(r"(?:\$(?:\w+:)?|\b)(\w+)\s*=(?!=)(?=([^;&\n]*))")
VAR_REF = re.compile(r"\$(?:\{[^}]*\}|(?:\w+:)?\w+)")
PUSH_FLAGS_OK = {"-u", "--set-upstream", "-q", "--quiet", "-v", "--verbose", "-n", "--dry-run"}
TICKET_BRANCH = re.compile(r"(^|/)vung-\d+", re.I)
PROTECTED_SEGMENTS = {"master", "main", "develop", "release"}
# Personal repos may push any non-protected branch; every other push rule still applies.
# The roots come from this machine's config only (never from the repo), so a team install allows none.


def norm_path(path):
    p = path.strip("\"'").replace("\\", "/").rstrip("/").lower()
    return re.sub(r"^/([a-z])(?=/|$)", r"\1:", p)  # Git Bash /d/... -> d:/...


def load_personal_roots():
    p = os.environ.get("KF_MACHINE_CONFIG") or os.path.expanduser("~/.claude/ngvu-factory/machine.json")
    try:
        roots = json.load(open(p, encoding="utf-8-sig")).get("personalRoots") or []
    except (OSError, ValueError, AttributeError):
        return []
    # only absolute drive paths; a bare drive or a relative path would open everything
    return [r for r in (norm_path(x) for x in roots if isinstance(x, str)) if re.match(r"^[a-z]:/.+", r)]


PERSONAL_ROOTS = load_personal_roots()
DIR_TARGET = re.compile(r"(?:(?<![\w-])-C|\b(?:cd|pushd|chdir|set-location|sl)\b)\s+(\"[^\"]*\"|'[^']*'|\S+)", re.I)
personal = False  # set by main() from the hook's cwd and the command's -C / cd targets
# A quoted argument is only scanned as a command when something on the line can run it.
INTERPRETERS = {"bash", "sh", "zsh", "dash", "cmd", "powershell", "pwsh", "eval", "iex",
                "invoke-expression", "xargs", "ssh", "wsl", "python", "python3", "py", "node",
                "perl", "start-process"}


def segments(command):
    """Split on shell separators outside quotes; newlines always split (heredoc bodies)."""
    out = []
    for line in command.split("\n"):
        cur, quote, i = [], None, 0
        while i < len(line):
            c = line[i]
            if quote:
                if c == "\\" and quote == '"' and i + 1 < len(line):
                    cur.append(line[i:i + 2])
                    i += 2
                    continue
                quote = None if c == quote else quote
            elif c in "'\"":
                quote = c
            else:
                m = SEPARATORS.match(line, i)
                if m:
                    out.append("".join(cur))
                    cur, i = [], m.end()
                    continue
            cur.append(c)
            i += 1
        out.append("".join(cur))
    return out


def tokens(segment):
    try:
        return shlex.split(segment, posix=True)
    except ValueError:
        return segment.split()


def base(tok):
    name = re.split(r"[\\/]", tok.strip("'\"&("))[-1].lower()
    return name[:-4] if name.endswith(".exe") else name


def git_reason(args):
    i = 0
    while i < len(args) and args[i].startswith("-"):
        if args[i] == "-c" and ALIAS_PUSH.search(" ".join(args[i + 1:i + 2])):
            return "git alias running push"
        i += 2 if args[i] in GIT_OPTS_WITH_ARG else 1
    if i >= len(args):
        return None
    sub, rest = args[i].lower(), args[i + 1:]
    flags = [a for a in rest if a.startswith("-")]
    short = "".join(a[1:] for a in flags if not a.startswith("--"))
    if sub == "push":
        return push_reason(rest)
    if sub == "reset" and "--hard" in rest:
        return "git reset --hard"
    if sub == "clean" and ("--force" in rest or "f" in short):
        return "git clean -f"
    if sub == "branch" and ("D" in short or ("--delete" in rest and "--force" in rest)
                            or ("d" in short and ("f" in short or "--force" in rest))):
        return "git branch force-delete"
    if sub == "config" and ALIAS_PUSH.search(" ".join(a for a in rest if not a.startswith("-"))):
        return "git alias running push"
    if sub == "checkout" and "." in rest:
        return "git checkout ."
    if sub == "restore" and "." in rest and not ("--staged" in rest and not (
            "--worktree" in rest or "W" in short)):
        return "git restore ."
    if sub == "checkout" and ("--force" in rest or "f" in short):
        return "git checkout --force"
    if sub == "switch" and ("--force" in rest or "--discard-changes" in rest or "f" in short):
        return "git switch --discard-changes"
    if sub == "stash" and rest[:1] in (["clear"], ["drop"]):
        return "git stash %s" % rest[0]
    if sub == "update-ref" and ("-d" in rest or "--delete" in rest):
        return "git update-ref -d"
    if sub == "worktree" and rest[:1] == ["remove"] and ("--force" in rest or "f" in short):
        return "git worktree remove --force"
    return None


def push_reason(rest):
    """None only for `push [safe flags] origin <ticket branch>`; anything else is blocked."""
    bad_flags = [a for a in rest if a.startswith("-") and a not in PUSH_FLAGS_OK]
    if bad_flags:
        return "git push with %s" % " ".join(bad_flags)
    pos = [a for a in rest if not a.startswith("-")]
    if len(pos) != 2 or pos[0] != "origin":
        return "git push without explicit 'origin <ticket branch>'"
    branch = pos[1]
    if re.search(r"[:+^~*?\[\\\s]", branch) or branch.upper() == "HEAD" or branch.startswith("refs/"):
        return "git push with refspec %s" % branch
    if {s.lower() for s in branch.split("/")} & PROTECTED_SEGMENTS:
        return "git push to protected branch %s" % branch
    if not TICKET_BRANCH.search(branch) and not personal:
        return "git push of non-ticket branch %s" % branch
    return None


def under_personal(path):
    p = norm_path(path)
    if not re.match(r"^[a-z]:/", p):  # relative: stays inside cwd unless it climbs or expands
        return not re.search(r"(^|/)\.\.(/|$)|^~|\$", p)
    return any(p == r or p.startswith(r + "/") for r in PERSONAL_ROOTS)


def is_personal(cwd, command):
    """True only when the session cwd and every -C / cd target lie under one personal root."""
    return bool(PERSONAL_ROOTS) and bool(cwd) and re.match(r"^[a-z]:", cwd, re.I) is not None \
        and under_personal(cwd) and all(under_personal(t) for t in DIR_TARGET.findall(command))


def acli_reason(args):
    words = {a.lower() for a in args if not a.startswith("-")}
    hit = sorted(words & ACLI_WRITE)
    return "acli write (%s)" % ", ".join(hit) if hit else None


def resolve_acli(command):
    """Spell what resolves to acli as the word acli, so scan() reads it like a literal acli.

    Returns the command with acli variables replaced (named after acli, or assigned from text that
    mentions acli, also through another variable), then a copy that also collapses each group
    mentioning acli, for `"$(ls .../acli.exe)" jira ...`. The caller still scans the original, so
    a command hidden inside a collapsed group is not lost.
    """
    def collapse(text):
        return ACLI_GROUP.sub(lambda m: "acli" if "acli" in m.group(0).lower() else m.group(0), text)

    while True:
        names = {n.lower() for n, rhs in ASSIGN.findall(collapse(command)) if "acli" in rhs.lower()}
        new = VAR_REF.sub(lambda m: "acli" if "acli" in m.group(0).lower()
                          or names & set(re.findall(r"\w+", m.group(0).lower())) else m.group(0), command)
        if new == command:
            return command + "\n" + collapse(command)
        command = new  # each pass turns at least one $var into acli, so this ends


def substitutions(text):
    """Commands bash runs inside text: $(...) and `...`, joined so they are still scanned."""
    return " ; ".join(a or b for a, b in SUBST.findall(text))


def heredoc_is_message(line, start):
    """True when the heredoc at `start` feeds git commit/tag/notes itself, or feeds `cat` inside the
    $(...) that is that command's message. A heredoc feeding any other command is still scanned."""
    piece = re.split(r"\|\||&&|[;|&]", line[:start])[-1]
    if "$(" in piece:
        before, inner = piece.rsplit("$(", 1)
        return inner.split()[:1] == ["cat"] and bool(GIT_MESSAGE_CMD.search(before))
    return bool(GIT_MESSAGE_CMD.search(piece))


def strip_messages(command):
    """Drop commit/tag message text, which is data, but keep any substitution bash would run in it.

    - the body of a heredoc opened on a `git commit|tag|notes` line (an unquoted delimiter keeps
      its $(...) substitutions, because bash expands them);
    - the quoted value of -m / --message (double quotes keep their substitutions).
    """
    out, lines, i = [], command.split("\n"), 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        m = HEREDOC.search(line)
        i += 1
        if m and heredoc_is_message(line, m.start()):
            body = []
            while i < len(lines) and lines[i].strip() != m.group(2):
                body.append(lines[i])
                i += 1
            if not m.group(1):
                out.append(substitutions("\n".join(body)))
    text = "\n".join(out)
    return MESSAGE_ARG.sub(lambda m: m.group(1) + " " + (substitutions(m.group(3)) if m.group(3)[0] == '"' else ""), text)


def scan(command, depth=0, nested=None):
    if depth == 0:
        command = strip_messages(command)
        # $(...) and `...` run even inside double quotes.
        command += "\n" + substitutions(command)
        command += "\n" + resolve_acli(command)
        nested = any(base(t) in INTERPRETERS for seg in segments(command) for t in tokens(seg))
    for segment in segments(command):
        toks = tokens(segment)
        for i, tok in enumerate(toks):
            name = base(tok)
            if name == "git":
                reason = git_reason(toks[i + 1:])
                if reason:
                    return reason
            elif name == "acli":
                reason = acli_reason(toks[i + 1:])
                if reason:
                    return reason
            elif nested and " " in tok and depth < 3:
                # Nested command strings: bash -c "...", powershell -Command "...", cmd /c "..."
                reason = scan(tok, depth + 1, nested)
                if reason:
                    return reason
    return None


def main():
    global personal
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
        command = payload.get("tool_input", {}).get("command") or ""
        personal = is_personal(payload.get("cwd") or "", command)
    except Exception:
        if re.search(r"\bgit\b", raw) and re.search(r"\bpush\b", raw):
            print("BLOCKED: unreadable hook input mentioning git push.", file=sys.stderr)
            sys.exit(2)
        sys.exit(0)
    reason = scan(command)
    if reason:
        print("BLOCKED by ngvu guardrail (%s). Only `git push [-u] origin <vung-ticket branch>` is "
              "allowed (or any non-protected branch under a configured personalRoots folder); protected-branch pushes, merges, destructive git and Jira writes are done by "
              "the human. Command: %s" % (reason, command), file=sys.stderr)
        sys.exit(2)
    sys.exit(0)


CASES = [
    ("git push origin main", True), ("git -C D:/workspace/services/example_core push -u origin x", True),
    ("rtk git push", True), ("cd repo && git push --force", True), ("bash -c \"git push\"", True),
    ("& 'C:\\Program Files\\Git\\cmd\\git.exe' push", True), ("git -c core.x=1 push", True),
    ("git reset --hard HEAD~1", True), ("git clean -fd", True), ("git branch -D old", True),
    ("git branch --delete --force old", True), ("git checkout .", True), ("git restore .", True),
    ("git worktree remove --force D:/wt", True),
    ("acli jira workitem edit --key VUNG-1", True), ("acli jira workitem transition --key VUNG-1", True),
    ("acli jira workitem comment create --key VUNG-1", True),
    ("git status", False), ("git log --grep push", False), ("git commit -m \"push fix\"", False),
    ("git fetch -q origin", False), ("git branch -d merged", False), ("git reset --soft HEAD~1", False),
    ("git worktree add -q --no-track -b b wt origin/master", False), ("git checkout -b feature", False),
    ("acli jira workitem view VUNG-1", False), ("acli jira workitem search --jql x", False),
    # acli reached through a path, a variable or a group is still acli (bypass of 2026-10-29).
    ("ACLI=$(ls -d \"$LOCALAPPDATA\"/Microsoft/WinGet/Packages/Atlassian.AtlassianCLI_*/acli_*/acli.exe"
     " | head -1); \"$ACLI\" jira workitem create --from-json f.json --json", True),
    ("A=$(command -v acli); B=\"$A\"; \"$B\" jira workitem transition --key VUNG-1", True),
    ("\"${ACLI:-acli}\" jira workitem delete --key VUNG-1", True),
    ("\"$(ls -d \"$LOCALAPPDATA\"/Microsoft/WinGet/Links/acli.exe)\" jira workitem create --from-json f", True),
    ("$(command -v acli) jira workitem assign --key VUNG-1", True),
    ("(\"$ACLI\" jira workitem edit --key VUNG-1)", True),
    ("\"/c/Users/u/AppData/Local/Microsoft/WinGet/Packages/Atlassian.AtlassianCLI_x/acli_1.3.4/acli.exe\""
     " jira workitem create --from-json f.json", True), ("acli.exe jira workitem delete --key VUNG-1", True),
    ("& \"$env:LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\Atlassian.AtlassianCLI_x\\acli_1.3.4\\acli.exe\""
     " jira workitem edit --key VUNG-1", True),
    ("$acli = (Get-ChildItem \"$env:LOCALAPPDATA\\Microsoft\\WinGet\\Packages\" -Recurse -Filter acli.exe"
     " | Select-Object -First 1).FullName; & $acli jira workitem create --from-json f.json", True),
    ("& $acli jira workitem edit --key VUNG-1", True),
    ("$x = (Get-Command acli).Source; & $x jira workitem transition --key VUNG-1 --status Done", True),
    ("& (Get-ChildItem \"$env:LOCALAPPDATA\\Microsoft\\WinGet\\Packages\" -Recurse -Filter acli.exe).FullName"
     " jira workitem create --from-json f.json", True),
    ("$r = (acli jira workitem create --from-json f.json --json | ConvertFrom-Json)", True),
    ("$r = (& $acli jira workitem create --from-json f.json --json | ConvertFrom-Json)", True),
    ("ACLI=$(ls -d \"$LOCALAPPDATA\"/Microsoft/WinGet/Packages/Atlassian.AtlassianCLI_*/acli_*/acli.exe"
     " | head -1); \"$ACLI\" jira workitem view VUNG-1 --json", False),
    ("\"$ACLI\" jira workitem search --jql \"project = VUNG\" --json", False), ("\"$ACLI\" jira auth status", False),
    ("$a = (Get-Command acli).Source; & $a jira workitem view VUNG-1 --json | ConvertFrom-Json", False),
    ("& \"$env:LOCALAPPDATA\\Microsoft\\WinGet\\Links\\acli.exe\" jira workitem search --jql x", False),
    ("F=$(ls *.json); cp \"$F\" archive", False), ("(git push origin master)", True),
    ("echo push", False), ("mvn clean install", False),
    # Commit and tag messages are data, not commands.
    ("git commit -m \"fix git push bug\"", False), ("git commit -am \"git push docs\"", False),
    ("git commit --message=\"blocks git push\"", False), ("git tag -a v1 -m \"no git push here\"", False),
    ("git -C D:/r commit -q -F - <<'EOF'\n- blocks every git push (incl. git -C <repo> push),\nEOF", False),
    ("git commit -m \"$(cat <<'EOF'\nblocks every git push\nEOF\n)\"", False),
    # ...but what runs around them is still checked.
    ("git commit -m \"x\" && git push", True),
    ("git commit -F - <<'EOF'\nmsg about git push\nEOF\ngit push origin b", True),
    ("bash <<'EOF'\ngit push\nEOF", True), ("echo \"git push\" | bash", True),
    ("git commit -m \"$(git push)\"", True),
    ("git commit -F - <<EOF\n$(git push)\nEOF", True),
    ("git commit -q -m x; sh <<'EOF'\ngit push\nEOF", True),
    ("git commit -m \"$(sh <<'EOF'\ngit push\nEOF\n)\"", True),
    ("git commit -m 'x' && git push", True), ("git tag -m \"x\" v1; git push --tags", True),
    # Push through an alias, and more ways to lose local work.
    ("git -c alias.p=push p origin b", True), ("git -c alias.p='!git push' p", True),
    ("git config alias.sync \"push origin HEAD\"", True), ("git config --global alias.pp push", True),
    ("git update-ref -d refs/heads/x", True), ("git stash clear", True), ("git stash drop", True),
    ("git checkout -f master", True), ("git checkout --force b", True),
    ("git switch --discard-changes b", True), ("git switch -f b", True),
    ("git restore --staged --worktree .", True), ("git restore -SW .", True),
    ("git restore --staged .", False), ("git stash list", False), ("git stash push -m wip", False),
    ("git update-ref refs/heads/x HEAD", False), ("git switch -c feature", False),
    ("git config alias.st status", False), ("git -c alias.lg=log lg", False),
    ("git commit -F - <<'EOF'\n$(git push) stays text: the delimiter is quoted\nEOF", False),
    # Ticket and epic branches may be pushed to origin; PRs to master are opened by the human.
    ("git push -u origin ngvu/vung-100003-revert-example-gate", False),
    ("git -C D:/workspace/.ngvu-worktrees/VUNG-1/example_core push -u origin ngvu/vung-1-x", False),
    ("git push -u origin ngvu/vung-100/EPIC-example", False),
    ("git push origin ngvu/vung-100/vung-101-child", False), ("git push -q origin VUNG-100004-x", False),
    ("git commit -q -m x && git push -u origin ngvu/vung-1-x", False),
    ("rtk git push -u origin ngvu/vung-1-x", False),
    ("git push", True), ("git push -u", True), ("git push origin", True), ("git push origin master", True),
    ("git push origin HEAD", True), ("git push origin HEAD:master", True),
    ("git push origin ngvu/vung-1-x:master", True), ("git push origin +ngvu/vung-1-x", True),
    ("git push origin vung-1-x master", True), ("git push upstream ngvu/vung-1-x", True),
    ("git push -f origin ngvu/vung-1-x", True), ("git push --force-with-lease origin vung-1-x", True),
    ("git push --all origin", True), ("git push --mirror origin", True), ("git push --tags origin vung-1", True),
    ("git push --delete origin ngvu/vung-1-x", True), ("git push -d origin vung-1-x", True),
    ("git push --no-verify origin vung-1-x", True), ("git push origin release/vung-1-x", True),
    ("git push origin develop", True), ("git push origin feature-x", True),
    ("git push origin refs/heads/vung-1-x", True), ("git push -o merge origin vung-1-x", True),
    ("git push origin vung-1-x && git push origin master", True),
    ("bash -c \"git push origin master\"", True), ("echo \"git push origin master\" | bash", True),
    # Text that only mentions push is data when nothing on the line can run it.
    ("grep -rlniE 'never push|git push|PR-description' skills", False),
    ("rg \"git push origin master\" .", False), ("echo \"run: git push origin master\"", False),
]

# (cwd, command, blocked?) — non-ticket branches only pass when cwd and every -C/cd target are personal.
PERSONAL_CASES = [
    ("D:\\Personal\\repos\\demo", "git push origin feat/demo-x", False),
    ("D:\\Personal\\repos\\demo", "cd \"D:/Personal/repos/demo\"; git push -u origin feat/x", False),
    ("D:\\Personal\\repos\\demo", "git -C /d/Personal/other push origin feat/x", False),
    ("D:\\Personal\\repos\\demo", "git push origin master", True),
    ("D:\\Personal\\repos\\demo", "git push -f origin feat/x", True),
    ("D:\\Personal\\repos\\demo", "git push origin feat/x:master", True),
    ("D:\\Personal\\repos\\demo", "git push", True),
    ("D:\\Personal\\repos\\demo", "git -C D:/workspace/services/example_core push origin feat/x", True),
    ("D:\\Personal\\repos\\demo", "cd D:/workspace/x && git push origin feat/x", True),
    ("D:\\Personal\\repos\\demo", "cd ../../workspace; git push origin feat/x", True),
    ("D:\\Personal\\repos\\demo", "cd $HOME/x; git push origin feat/x", True),
    ("D:\\PersonalX\\r", "git push origin feat/x", True),
    ("D:\\workspace\\example_core", "git push origin feat/x", True),
    ("D:\\workspace\\example_core", "cd D:/Personal/x; git push origin feat/x", True),
]

if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        bad = [(c, e) for c, e in CASES if bool(scan(c)) != e]
        configured, PERSONAL_ROOTS = PERSONAL_ROOTS, ["d:/personal"]  # fixture root for the cases
        for cwd, c, e in PERSONAL_CASES:
            personal = is_personal(cwd, c)
            if bool(scan(c)) != e:
                bad.append(("[cwd %s] %s" % (cwd, c), e))
        PERSONAL_ROOTS = []  # no personalRoots in machine.json: a personal folder is like any other
        personal = is_personal("D:\\Personal\\r", "git push origin feat/x")
        if not scan("git push origin feat/x"):
            bad.append(("[no personalRoots] git push origin feat/x", True))
        PERSONAL_ROOTS, personal = configured, False
        for c, e in bad:
            print("FAIL: expected %s for: %s" % ("block" if e else "allow", c))
        print("self-test: %d cases, %d failed" % (len(CASES), len(bad)))
        sys.exit(1 if bad else 0)
    main()
