source "$(dirname "$0")/lib/assert.sh"
P="$KF_ROOT/presentation/index.html"; h=$(cat "$P" 2>/dev/null)
assert_contains "<title>ngvu-ai-factory</title>" "$h" "title"
assert_eq 16 "$(grep -c '<section class="slide' "$P" 2>/dev/null)" "16 slides"
assert_eq 0 "$(grep -cE '(src|href)="https?://' "$P" 2>/dev/null)" "no external resources"
for s in "Why one repo" "What you install" "Install on a machine" "Ticket flow" "How the agents trigger" "Intake gates" "Review lenses" "Escalation" "Test gate" "After the PR" "Epic flow" "Guardrails" "Daily commands" "Engineering skills" "Rollout and Questions"; do
  assert_contains "data-title=\"$s\"" "$h" "slide '$s'"
done
assert_contains '<svg' "$h" "agent trigger diagram is drawn"
for t in "spec-writer" "builder" "security-tenancy" "code-conventions" "contract-integration" "data-persistence" "frontend-ui" "approver" "WAIT FOR ALL" "builderAgentId" "needs-human" "ready-for-pr" "pushed + PR link"; do
  assert_contains "$t" "$h" "diagram shows $t"
done
for f in "ngvu-kit.ps1 bootstrap" "machine.json" "onFailure: block" "it-results.md" "pr-feedback" "/ngvu-factory:ngvu-factory"; do
  assert_contains "$f" "$h" "deck covers $f"
done
for stale in "never collide" "cross-team repos, CMS" "D:\workspace\scripts\mvn-unit.bat</code> in every" "Install tip: deny <code>Bash(git push:*)</code> in your settings" "You push" "you push" "blocks every push" "local commit" "Related IT not run"; do
  assert_not_contains "$stale" "$h" "no stale text: $stale"
done
assert_contains "ArrowRight" "$h" "keyboard navigation"
# dark-cyan deck theme contract (deck-theme-v1)
for m in "#07111f" "#6ee7ff" 'id="prev"' 'id="next"' 'id="tocBtn"' 'class="progress"' 'id="counter"' 'class="kicker"' 'class="slide-num"' "@media print" "k==='m'||k==='t'" 'Menu (M)'; do
  assert_contains "$m" "$h" "deck theme marker $m"
done
assert_eq "$(grep -c '<section class="slide' "$P")" "$(grep -o 'data-title="[^"]*"' "$P" | wc -l | tr -d ' ')" "every slide has data-title (drives the TOC)"
assert_eq "$(grep -c '<section class="slide' "$P")" "$(grep -c 'class="slide-num"' "$P")" "every slide has a slide number"
assert_contains "presentation/index.html" "$(cat "$KF_ROOT/README.md")" "README links the presentation"
out=$(python "$KF_ROOT/tests/lint_text.py" "$KF_ROOT/presentation" 2>&1); assert_eq 0 "$?" "presentation clean: $out"
# Editable Excalidraw source of the agent trigger diagram (dark-cyan deck theme palette, dark canvas)
X="$KF_ROOT/presentation/ngvu-factory-agent-flow.excalidraw"
out=$(python - "$X" <<'PY' 2>&1
import json, sys
THEME = {"#07111f","#0d1b2a","#10253b","#eef6ff","#9bb2c7","#6ee7ff","#fbbf24","#34d399","#fb7185","#a78bfa","#24445f","transparent"}
d = json.load(open(sys.argv[1], encoding="utf-8"))
assert d["type"] == "excalidraw" and isinstance(d["version"], int), "not an excalidraw scene"
assert d["appState"]["viewBackgroundColor"].lower() == "#07111f", "canvas is not the theme navy"
assert isinstance(d["files"], dict)
els = d["elements"]
ids = [e["id"] for e in els]
assert len(ids) == len(set(ids)), "duplicate element ids"
bad = sorted({str(e.get(k, "")).lower() for e in els for k in ("strokeColor", "backgroundColor")} - THEME)
assert not bad, "colours outside the deck theme: %s" % bad
texts = " ".join(e.get("text", "") for e in els if e["type"] == "text")
for t in ["spec-writer", "builder", "security-tenancy", "code-conventions", "contract-integration", "data-persistence", "frontend-ui", "approver", "WAIT FOR ALL", "builderAgentId", "needs-human", "ready-for-pr", "You approve"]:
    assert t in texts, "missing label " + t
byid = {e["id"]: e for e in els}
for e in els:
    if e["type"] == "text" and e.get("containerId"):
        c = byid[e["containerId"]]
        assert any(b["id"] == e["id"] for b in c["boundElements"]), "container does not list its text " + e["id"]
assert sum(1 for e in els if e["type"] == "arrow") >= 15, "too few arrows"
print("ok")
PY
)
assert_eq ok "$out" "excalidraw source is valid and uses the deck theme colours: $out"
kf_finish
