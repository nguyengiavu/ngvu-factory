# Anatomy of a report page

The shared set of presentation blocks for the three HTML document kinds (incident/RCA · QA verification ·
stakeholder one-pager). The template `assets/report-template.html` already has CSS for every block
below — **replace the content, do not rewrite the CSS**.

General rule: each block exists to answer **one question**. A block that answers no question only
makes the document longer.

---

## Required blocks, in order

### 1. Eyebrow — document kind and position in the set

One line of small text above the title: document kind · scope. For example
`QA Test Report · example-docs` or `Report 2 of 2 · DNS infrastructure root cause`.

If there is a companion document, **insert the cross-link right here** with one sentence that says which
line this document covers and which line the other one covers.

### 2. Title — a statement or a question

See [quality-bar.md](quality-bar.md#1-title). Do not use a label.

### 3. Context strip

One row of label–value pairs, so that six months later you still know what the document is about:

```
Env · Build/commit · Component · Date · Method
```

For an incident report use instead: `Focus (date) · Env · Scope (service) · Root cause`.

### 4. Verdict banner

A coloured block right under the context strip, holding:
- the big number or conclusion (`3 / 3 PASS`, `Root cause: DNS`)
- one sentence in plain language
- one sentence on where the evidence is

Use semantic colour: green for pass, red for broken, amber for "a finding, but not a
bug". Semantic colour is **kept apart from** the page accent colour.

---

## Blocks by document kind

### Only in QA verification

**Section 0 — "How to read this report"**, a table that translates terms into plain language. This is the section
that makes the biggest difference to how much the document gets read. Each row: term → what it means **here** → and
when needed, *which number is a good sign*.

End this section with an "In one sentence" callout: what the bug does, what the fix does, which number proves
it.

**Pass criteria section** — a table `#` · `Claim` · `Pass condition`; thresholds must be countable.

**Test data** — a table with a **"why chosen"** column. Add one line that says clearly **what was changed and what was
not changed**: *"No data was modified. Only two marker keys were deleted per run."*

**Base procedure** — a table `Step` · `Action` · `Expected / how to check`. If a test case departs from
this procedure, explain **why** right there.

**Result card per case** — one card per case: id + one-line goal + verdict label; numbered
steps; **a chip per request** (`req#1 · 10:15:36 · 200 · Mongo read` / `req#2 · cached`); an
observed–expected block; a trimmed log excerpt; and **a button that opens Cloud Logging**.

**Edge case section** — things found that are not bugs. Give them their own label (not PASS/FAIL)
and explain why they are not bugs.

**Environment & reproduction** — cluster/namespace, deployed image, endpoint, rerun command, evidence
source. Add **known limits of the test set** if any.

### Only in incident / RCA

**Section "two hypotheses — only one survives"** — state the rejected hypothesis and the evidence that rejected it.

**Mechanism section** — the chain of events from cause to symptom. This is where an SVG diagram goes: draw
**the chain**, not a generic architecture diagram.

**Section "why this time and not another time"** — the trigger conditions. Almost always two
conditions coinciding; name both and say what happens if only one is present.

**Timeline** — UTC timestamps with events. Use monospace for the time column.

**Recommendations** — numbered; each item says which part of the mechanism chain above it blocks.

### Only in stakeholder one-pager

Cut all class names, internal environment names and logs. Keep: current status, what is done, what is
left, risks, and **what the reader needs to decide**. If there is nothing for them to decide, say clearly that it is
an information bulletin and no action is needed.

---

## Shared blocks

| Block | Use when |
|---|---|
| Table in a scroll frame | Every table — so the page does not scroll sideways |
| Dark log block | Real log excerpts. Always trim, highlight the important part, add a `←` note on the line that matters |
| Open in Cloud Logging button | Every claim based on logs. The time range must match the actual run |
| Callout | Explaining a design decision or warning about a common misunderstanding |
| Status chip | A short chain of events to compare side by side (requests, attempts, environments) |
| Confidence label | A sentence not yet confirmed by a primary source |
| Small caption under a table | Limits, conditions, things that were not measured |

---

## Footer

One line that repeats: document kind · audience · environment · date · method. People often take a
screenshot of this part to paste into chat.
