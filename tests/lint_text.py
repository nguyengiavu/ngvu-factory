"""Fail if shipped text contains non-English letters or real-looking UUIDs (data policy).

Usage: lint_text.py <dir>...      scan those folders
       lint_text.py --repo <root>  scan every file git tracks under <root> (the whole published repo)
"""
import os, re, subprocess, sys

# Latin-1 letters, Latin Extended A/B and Latin Extended Additional (Vietnamese); the multiplication
# and division signs (U+00D7, U+00F7) are punctuation, not letters.
VI = re.compile("[%s-%s%s-%s%s-%s%s-%s]" % tuple(map(chr, (0xC0, 0xD6, 0xD8, 0xF6, 0xF8, 0x24F, 0x1E00, 0x1EFF))))
UUID = re.compile(r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b")
ZERO = "00000000-0000-0000-0000-000000000000"
EXT = (".md", ".html", ".js", ".mjs", ".json", ".sh", ".py", ".ps1", ".txt", ".yaml", ".yml",
       ".toml", ".tsv", ".bat", ".cmd", ".css")


def paths(args):
    if args[:1] == ["--repo"]:
        root = args[1]
        out = subprocess.run(["git", "-C", root, "ls-files", "-z"], capture_output=True, check=True).stdout
        return [os.path.join(root, f) for f in out.decode("utf-8").split("\0") if f]
    return [os.path.join(d, n) for root in args for d, _, files in os.walk(root) for n in files]


problems = []
for path in paths(sys.argv[1:]):
    if not path.endswith(EXT):
        continue
    try:
        lines = open(path, encoding="utf-8").readlines()
    except (OSError, UnicodeDecodeError):
        continue
    for n, line in enumerate(lines, 1):
        if VI.search(line):
            problems.append("%s:%d non-English letter" % (path, n))
        for u in UUID.findall(line):
            if u != ZERO:
                problems.append("%s:%d UUID %s" % (path, n, u))
print("\n".join(problems))
sys.exit(1 if problems else 0)
