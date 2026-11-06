#!/usr/bin/env bash
# breakdown.sh — check the "## Factory queue" table in 08-STORY-BREAKDOWN.md of an epic folder.
#
#   bash breakdown.sh <epic-folder>          # report for a human reader
#   bash breakdown.sh <epic-folder> --json   # JSON for /ngvu-factory epic
#
# Checks: columns in the right order; Story S<n> and Jira key not duplicated; Repos/Owner not empty;
# "Blocked by" only points to an S<n> in the table or to VUNG-<n>; no dependency cycle;
# coverage both ways: every R<n> in the R-list of 01-EPIC-AND-CONTEXT.md is Covered by at least one
# story, and every story Covers at least one R<n> that exists.
# Exit: 0 valid · 2 invalid (errors on stderr) · 3 missing file/section · 1 usage.
set -uo pipefail

dir="${1:-}"; mode="${2:-}"
[ -n "$dir" ] && [ -d "$dir" ] || { sed -n '2,11p' "$0" >&2; exit 1; }
py=""
for c in "${KF_PYTHON:-}" python python3 py; do
  [ -n "$c" ] && "$c" -c 'import sys' >/dev/null 2>&1 && { py="$c"; break; }
done
[ -n "$py" ] || { echo "python not found (set KF_PYTHON)" >&2; exit 1; }
native() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi; }

PYTHONIOENCODING=utf-8 "$py" - "$(native "$dir")" "$mode" <<'PY' | tr -d '\r'
import json, os, re, sys
d, mode = sys.argv[1], sys.argv[2]
COLS = ["Story", "Jira", "Summary", "Repos", "Owner", "Blocked by", "Covers"]
NONE = {"", "-", "—", "–"}

def section(path, test):
    if not os.path.isfile(path):
        print("missing file: " + path, file=sys.stderr); sys.exit(3)
    out, on = [], False
    for line in open(path, encoding="utf-8-sig"):
        if line.startswith("## "):
            if on: break
            on = test(line)
            continue
        if on: out.append(line.rstrip("\n"))
    return out if on or out else None

def cells(line):
    return [re.sub(r"[*`]", "", c).strip() for c in line.strip().strip("|").split("|")]

def items(s):
    return [] if s in NONE else [x.strip() for x in s.split(",") if x.strip()]

rows = section(os.path.join(d, "08-STORY-BREAKDOWN.md"), lambda h: h.strip() == "## Factory queue")
if rows is None:
    print("08-STORY-BREAKDOWN.md has no '## Factory queue' section", file=sys.stderr); sys.exit(3)
rlist = section(os.path.join(d, "01-EPIC-AND-CONTEXT.md"), lambda h: "R-list" in h) or []
rdefined = sorted({int(m.group(1)) for l in rlist for m in [re.match(r"^\|\s*\**R(\d+)\b", l)] if m})

errs, warns, stories = [], [], []
# An unfilled scaffold must not count as "done": empty R rows, story rows still holding template text.
for l in rlist:
    m = re.match(r"^\|\s*\**R(\d+)\b", l)
    if m and (len(cells(l)) < 2 or cells(l)[1] in NONE):
        errs.append("01 R-list: R%s has no requirement text" % m.group(1))
PLACEHOLDER = re.compile(r"<[^>|]+>|\brepo_name\b")
table = [cells(l) for l in rows if l.strip().startswith("|")]
if not table or table[0] != COLS:
    errs.append("header row must be exactly: | " + " | ".join(COLS) + " |")
for r in table[2:] if table and table[0] == COLS else []:
    if len(r) != len(COLS):
        errs.append("wrong number of columns: | " + " | ".join(r) + " |"); continue
    s = dict(zip(COLS, r))
    sid = s["Story"]
    if any(PLACEHOLDER.search(v) for v in r): errs.append("%s: row still holds template text (<...> / repo_name)" % sid)
    if not re.fullmatch(r"S\d+", sid): errs.append("%s: Story must have the form S<n>" % sid)
    key = None if s["Jira"] in NONE else s["Jira"]
    if key and not re.fullmatch(r"VUNG-\d+", key): errs.append("%s: Jira must be VUNG-<n> or —" % sid)
    if not key: warns.append("%s has no Jira key: the factory will not queue this story" % sid)
    repos = items(s["Repos"])
    if not repos or any(not re.fullmatch(r"[A-Za-z0-9_.-]+", x) for x in repos):
        errs.append("%s: Repos must be a list of repo names, separated by commas" % sid)
    if s["Owner"] in NONE: errs.append("%s: Owner is empty" % sid)
    blk = items(s["Blocked by"])
    for b in blk:
        if not re.fullmatch(r"S\d+|VUNG-\d+", b): errs.append("%s: Blocked by '%s' is not S<n>/VUNG-<n>" % (sid, b))
    cov = items(s["Covers"])
    for c in cov:
        if not re.fullmatch(r"R\d+", c): errs.append("%s: Covers '%s' must be R<n> (no ranges like R1–R3)" % (sid, c))
    if not cov: errs.append("%s: Covers is empty — the story serves no requirement" % sid)
    stories.append({"story": sid, "key": key, "summary": s["Summary"], "repos": repos,
                    "owner": s["Owner"], "blockedBy": blk, "covers": cov})

ids = [x["story"] for x in stories]
keys = [x["key"] for x in stories if x["key"]]
for v, what in ((ids, "Story"), (keys, "Jira")):
    for x in sorted({x for x in v if v.count(x) > 1}): errs.append("duplicate %s: %s" % (what, x))
if not stories and not errs: errs.append("the Factory queue table has no rows")
by_id = {x["story"]: x for x in stories}
by_key = {x["key"]: x["story"] for x in stories if x["key"]}
for x in stories:
    for b in x["blockedBy"]:
        if b.startswith("S") and b not in by_id: errs.append("%s: Blocked by %s is not in the table" % (x["story"], b))
        if b == x["story"] or by_key.get(b) == x["story"]: errs.append("%s blocks itself" % x["story"])

# dependency cycle inside the table (S<n> and the VUNG keys of stories in the table)
deps = {x["story"]: {by_key.get(b, b) for b in x["blockedBy"]} & set(by_id) for x in stories}
done = set()
while len(done) < len(deps):
    ready = [k for k in deps if k not in done and deps[k] <= done]
    if not ready:
        errs.append("dependency cycle between: " + ", ".join(k for k in deps if k not in done)); break
    done.update(ready)

if not rdefined: errs.append("01-EPIC-AND-CONTEXT.md: no R-list found (section '## ... R-list' with rows '| R1 | ...')")
covered = {int(c[1:]) for x in stories for c in x["covers"] if re.fullmatch(r"R\d+", c)}
for r in rdefined:
    if r not in covered: errs.append("R%d is not Covered by any story" % r)
for r in sorted(covered - set(rdefined)):
    if rdefined: errs.append("Covers R%d but the R-list has no R%d" % (r, r))

if errs:
    for e in errs: print("ERROR: " + e, file=sys.stderr)
    for w in warns: print("WARNING: " + w, file=sys.stderr)
    sys.exit(2)

# The factory only queues child tickets that have an investigation folder at the tasks/ level (next to the epic folder).
tasks = os.path.dirname(os.path.abspath(d))
names = os.listdir(tasks) if os.path.isdir(tasks) else []
for x in stories:
    if x["key"] and not any(n == x["key"] or n.startswith(x["key"] + "-") for n in names):
        warns.append("%s (%s) has no child folder: run new-child.sh" % (x["story"], x["key"]))

for x in stories:
    x["blockedByKeys"] = sorted({by_id[b]["key"] if b in by_id else b for b in x["blockedBy"]} - {None})
    x["blockedByUnkeyed"] = [b for b in x["blockedBy"] if b in by_id and not by_id[b]["key"]]
if mode == "--json":
    print(json.dumps({"stories": stories, "requirements": ["R%d" % r for r in rdefined], "warnings": warns},
                     ensure_ascii=False, indent=2))
else:
    print("Valid: %d stories, all %d requirements R are covered, no dependency cycle." % (len(stories), len(rdefined)))
    for w in warns: print("WARNING: " + w)
PY
exit "${PIPESTATUS[0]}"
