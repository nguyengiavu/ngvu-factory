"""Generate presentation/ngvu-factory-agent-flow.excalidraw.

The editable Excalidraw source of slide 7 ("How the agents trigger"), in the dark-cyan deck
theme palette (deck-theme-v1). Layout coordinates match the SVG on the slide (scaled), element ids are
deterministic so a regenerated scene diffs cleanly.

Usage: python tools/gen-agent-flow-excalidraw.py
"""
import json
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "presentation" / "ngvu-factory-agent-flow.excalidraw"

# dark-cyan deck theme tokens (deck-theme-v1)
BG, PANEL2, TEXT, MUTED = "#07111f", "#10253b", "#eef6ff", "#9bb2c7"
CYAN, AMBER, GREEN, RED, PURPLE = "#6ee7ff", "#fbbf24", "#34d399", "#fb7185", "#a78bfa"

S = 1.6          # scale from the slide SVG (viewBox 1200 x 605)
OY = 90          # room for the title
SANS, MONO = 2, 3  # Excalidraw font families: 2 = Helvetica, 3 = Cascadia
UPDATED = 1792000000000

elements = []
seed = [100]


def base(eid, etype, x, y, w, h, stroke, bg="transparent", width=2, style="solid"):
    seed[0] += 1
    return {
        "id": eid, "type": etype, "x": round(x, 1), "y": round(y, 1), "width": round(w, 1), "height": round(h, 1),
        "angle": 0, "strokeColor": stroke, "backgroundColor": bg, "fillStyle": "solid",
        "strokeWidth": width, "strokeStyle": style, "roughness": 0, "opacity": 100,
        "groupIds": [], "frameId": None, "index": None, "roundness": None,
        "seed": seed[0], "version": 1, "versionNonce": seed[0] * 7919, "isDeleted": False,
        "boundElements": None, "updated": UPDATED, "link": None, "locked": False,
    }


def text_size(lines, size, family):
    char_w = 0.6 if family == MONO else 0.55
    return max(len(l) for l in lines) * size * char_w, len(lines) * size * 1.25


def free_text(eid, x, y, s, color, size=17, family=SANS, align="left"):
    lines = s.split("\n")
    w, h = text_size(lines, size, family)
    if align == "center":
        x -= w / 2
    e = base(eid, "text", x, y, w, h, color)
    e.update({"text": s, "fontSize": size, "fontFamily": family, "textAlign": align,
              "verticalAlign": "top", "containerId": None, "originalText": s,
              "autoResize": True, "lineHeight": 1.25})
    elements.append(e)


def box(eid, x, y, w, h, stroke, label, width=2, style="solid", size=17, family=SANS, bg=PANEL2):
    """A rounded node with its label bound inside (editable as one shape in Excalidraw)."""
    X, Y, W, H = x * S, y * S + OY, w * S, h * S
    r = base(eid, "rectangle", X, Y, W, H, stroke, bg, width, style)
    r["roundness"] = {"type": 3}
    tid = eid + "-text"
    r["boundElements"] = [{"type": "text", "id": tid}]
    elements.append(r)
    lines = label.split("\n")
    tw, th = text_size(lines, size, family)
    t = base(tid, "text", X + (W - tw) / 2, Y + (H - th) / 2, tw, th, TEXT)
    t.update({"text": label, "fontSize": size, "fontFamily": family, "textAlign": "center",
              "verticalAlign": "middle", "containerId": eid, "originalText": label,
              "autoResize": True, "lineHeight": 1.25})
    elements.append(t)


def label(eid, x, y, s, color, size=16, align="center", family=SANS):
    free_text(eid, x * S, y * S + OY, s, color, size, family, align)


def arrow(eid, pts, color, style="solid", width=2, head=True):
    P = [(x * S, y * S + OY) for x, y in pts]
    x0, y0 = P[0]
    rel = [[round(x - x0, 1), round(y - y0, 1)] for x, y in P]
    xs, ys = [p[0] for p in rel], [p[1] for p in rel]
    a = base(eid, "arrow", x0, y0, max(xs) - min(xs), max(ys) - min(ys), color, "transparent", width, style)
    a.update({"points": rel, "lastCommittedPoint": None, "startBinding": None, "endBinding": None,
              "startArrowhead": None, "endArrowhead": "arrow" if head else None, "elbowed": False})
    a["roundness"] = None
    elements.append(a)


# Title
free_text("title", 10 * S, 18, "ngvu-factory - how the agents trigger", TEXT, 34)
free_text("subtitle", 10 * S, 62, "One ticket: orchestrator (cyan), agents (purple), your actions (amber), outcomes (green / red)", MUTED, 17)

# Main row
box("intake", 10, 182, 125, 70, CYAN, "Intake\nJira + tasks\nticket.json")
box("approve-intake", 160, 182, 120, 70, AMBER, "You approve\nthe intake", style="dashed")
box("worktree", 305, 182, 120, 70, CYAN, "Worktree\nworktree-setup.sh\nnew branch")
box("spec-writer", 450, 182, 125, 70, PURPLE, "spec-writer\nopus\n-> spec.md")
box("builder", 600, 182, 125, 70, PURPLE, "builder\nopus, commits\n-> build.md")
for i, (a, b) in enumerate([(135, 160), (280, 305), (425, 450), (575, 600)]):
    arrow(f"a-main-{i}", [(a, 217), (b - 4, 217)], MUTED)

# Lenses in parallel; frontend-ui only with nextjs repos
label("lbl-parallel", 840, 52, "spawned in ONE message, run in parallel", MUTED, 15)
lenses = [("security-tenancy", "opus", 85), ("code-conventions", "sonnet, re-runs UT", 141),
          ("contract-integration", "sonnet, catalog", 197), ("data-persistence", "sonnet", 253),
          ("frontend-ui", "only nextjs", 309)]
for name, model, y in lenses:
    box("lens-" + name, 765, y, 150, 46, PURPLE, f"{name}\n{model}", size=16,
        style="dashed" if name == "frontend-ui" else "solid")
label("lbl-reviews", 840, 360, "-> round-N/review-*.md", MUTED, 14, family=MONO)
arrow("a-fan-0", [(725, 217), (745, 217), (745, 108), (761, 108)], MUTED)
arrow("a-fan-1", [(745, 164), (761, 164)], MUTED)
arrow("a-fan-2", [(745, 220), (761, 220)], MUTED)
arrow("a-fan-3", [(745, 220), (745, 276), (761, 276)], MUTED)
arrow("a-fan-4", [(745, 276), (745, 332), (761, 332)], MUTED)

# WAIT FOR ALL join
j = base("join", "rectangle", 934 * S, 85 * S + OY, 7 * S, 270 * S, CYAN, CYAN, 1)
elements.append(j)
label("lbl-wait", 937, 70, "WAIT FOR ALL", CYAN, 16)
for i, (_, _, y) in enumerate(lenses):
    arrow(f"a-in-{i}", [(915, y + 23), (931, y + 23)], MUTED, head=False)

# Approver and outcomes
box("approver", 960, 182, 105, 70, PURPLE, "approver\n8 triggers\n-> decision.md", size=16)
arrow("a-approver", [(941, 217), (956, 217)], MUTED)
label("lbl-allpass", 1012, 262, "all PASS", MUTED, 14)
box("ready", 1090, 95, 105, 54, GREEN, "ready-for-pr\npushed + PR link", width=4, size=16)
box("needs-human", 1090, 300, 105, 54, RED, "needs-human\nreason quoted", width=4, size=16)
label("lbl-approve", 1142, 80, "APPROVE", GREEN, 14)
label("lbl-escalate", 1050, 284, "ESCALATE", RED, 14)
arrow("a-approve", [(1065, 205), (1077, 205), (1077, 122), (1086, 122)], GREEN)
arrow("a-escalate", [(1065, 229), (1077, 229), (1077, 327), (1086, 327)], RED)

# You: approve an ESCALATE
arrow("a-human-approve", [(1172, 300), (1172, 153)], AMBER, "dashed")
label("lbl-human-approve", 1132, 216, "you:\n/approve", AMBER, 14)

# Review loop
arrow("a-loop", [(937, 355), (937, 410), (682, 410), (682, 256)], CYAN, width=3)
label("lbl-loop", 812, 380, "any CHANGES: SendMessage\nto builderAgentId (max 2 resumes)", CYAN, 14)
arrow("a-no-resumes", [(937, 410), (1150, 410), (1150, 358)], RED, "dashed")
label("lbl-no-resumes", 1040, 392, "no resumes left", RED, 14)

# BLOCKED
arrow("a-blocked-spec", [(525, 252), (525, 470), (1165, 470), (1165, 358)], RED, "dashed")
arrow("a-blocked-build", [(640, 252), (640, 470)], RED, "dashed", head=False)
label("lbl-blocked", 800, 452, "spec or build BLOCKED", RED, 14)

# Rework
arrow("a-rework-build", [(1118, 354), (1118, 530), (662, 530), (662, 256)], AMBER, "dashed")
arrow("a-rework-spec", [(662, 530), (500, 530), (500, 256)], AMBER, "dashed")
label("lbl-rework", 890, 512, "you: /rework -> fresh builder (or spec-writer when the spec was BLOCKED)", AMBER, 14)

# Legend
legend_y = 560
for i, (stroke, style, txt) in enumerate([(CYAN, "solid", "orchestrator (this session): runs scripts, pushes, only writer of ticket.json"),
                                          (PURPLE, "solid", "agent: writes exactly one file, verdict on line 1"),
                                          (AMBER, "dashed", "you: approvals, rework, the PR")]):
    x = [10, 470, 810][i]
    r = base(f"legend-box-{i}", "rectangle", x * S, legend_y * S + OY, 18 * S, 14 * S, stroke, PANEL2, 2, style)
    elements.append(r)
    free_text(f"legend-text-{i}", (x + 24) * S, legend_y * S + OY + 2, txt, MUTED, 15)
for i, (color, style, txt, x) in enumerate([(MUTED, "solid", "hand-off", 10), (CYAN, "solid", "review loop", 170),
                                            (RED, "dashed", "stop: BLOCKED / no resumes", 340),
                                            (AMBER, "dashed", "your action", 580)]):
    arrow(f"legend-line-{i}", [(x, 590), (x + 30, 590)], color, style)
    free_text(f"legend-line-text-{i}", (x + 38) * S, 590 * S + OY - 10, txt, MUTED, 15)

scene = {
    "type": "excalidraw",
    "version": 2,
    "source": "https://excalidraw.com",
    "elements": elements,
    "appState": {"gridSize": 20, "viewBackgroundColor": BG},
    "files": {},
}
OUT.write_text(json.dumps(scene, indent=2) + "\n", encoding="utf-8", newline="\n")
print(f"wrote {OUT} ({len(elements)} elements)")
