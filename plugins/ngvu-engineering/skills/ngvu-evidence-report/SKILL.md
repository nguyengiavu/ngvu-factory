---
name: ngvu-evidence-report
description: "Builds and reviews evidence-backed ngvu deliverables: incident/RCA reports, QA verification reports, stakeholder one-pagers and Jira story descriptions, verdict first with every claim sourced and a QA gate before handoff. Use when asked to write or review a report, RCA write-up, test report, one-pager or story (write a report, QA report). For a live outage use incident-response."
---

# Evidence-backed deliverables

This skill produces documents that the reader **can verify on their own**, without taking the
writer's word for it. It is distilled from deliverables the team has approved, so the goal is not
"write more" but **write so that others can reuse and check it**.

This skill is about **presentation and way of working**, not about code.

---

## Where it fits in the team framework

An agent framework with four agents uses this skill: Testing · Reporting · Ops ·
Product Engineer. This skill serves the **Reporting** agent and the output side of the other three.

This skill follows two conventions of that framework. Keep them: they are why the agents fit
together.

**1. The skill stays generic; domain knowledge is loaded separately.** Do not embed service names,
collection names or environment conventions in the skill. They live in a **grounding pack** with
citations, loaded at run time. This way the same skill writes a report for `example-docs` today and for
another service next month.

**2. Every fact carries its source, in this source priority: `code > Jira > wiki`.** When two
sources conflict, code wins — and **say that they conflict**, do not quietly pick one side. That is
often the most valuable finding in the whole document.

The default autonomy level is **L0–L1**: read freely, but every outward action (writing to Jira,
publishing to stakeholders, sending to a wiki) needs the user's go first.

---

## Four kinds of deliverable

| Kind | Question it answers | Read more |
|---|---|---|
| **Incident / RCA** | "Why did the system break, and why at that moment?" | [references/report-anatomy.md](references/report-anatomy.md) |
| **QA verification** | "Does this fix really work in a real environment?" | [references/report-anatomy.md](references/report-anatomy.md) |
| **Stakeholder one-pager** | "Where is the work, and what does the reader need to decide?" | [references/report-anatomy.md](references/report-anatomy.md) |
| **Story / epic description** | "What needs to be done, and when is the story closed?" | [references/quality-bar.md](references/quality-bar.md) |

The first three are self-contained HTML pages, **saved locally by default** (see Step 5). Publish
as an Artifact only when the user asks for it explicitly. The fourth is text in Jira, but with
**the same evidence discipline**.

---

## Nine habits that create quality

This part is distilled from approved deliverables. It matters far more than the template.
Details and side-by-side examples: [references/quality-bar.md](references/quality-bar.md).

**1. Conclusion at the top.** The first reader often needs to decide within 30 seconds. A verdict
banner (`3 / 3 PASS`) or one bold concluding sentence right under the title. The details sit below
for those who want to verify.

**2. The title is a statement or a question, not a label.**
*"MongoDB incident analysis 08/09"* is a label. *"The morning MongoDB timeouts are a DNS incident — not
database overload"* is a statement: it also names **what was ruled out**.

**3. State the current situation before the work to do.** The strongest technique in the team's
good stories is the **"Today" table**: each sub-behaviour × state (`Exists` / `Partial` / `Missing`)
with concrete evidence. It turns a vague request into a countable delta, and prevents
over-estimating parts that already exist.

**4. Separate effort from scope.** "Most of it already exists, so this is a delta" affects
**effort**, not **scope** or what must be proven to close the work. Mixing the two is the most
common way a story gets closed too early.

**5. Write traps as a symptom chain, not a code smell.** Compare:
- Weak: *"`getUnprocessFile` does not handle files correctly."*
- Strong: *"if metadata is not excluded here → the unprocessed list never drains → the job looks
  hung → the system invents a TIMEOUT for a transfer that actually succeeded."*

The symptom chain tells the reader **what they will see** when the trap fires.

**6. Record rejected hypotheses too.** If you first suspected a MongoDB OOM and the evidence ruled
it out, write down that path — the next reader will suspect exactly what you suspected. Make it a
section "two hypotheses — only one survives".

**7. State what you could NOT prove.** An example worth learning from: three test cases fired
requests 40 seconds apart, well within the first-tier cache lifetime — so they **could not**
tell an in-pod cache from a shared cache. The writer spotted that gap and designed an extra case
that waits 330 seconds to close it. Finding the gaps in your own evidence is the clearest sign of a
trustworthy document.

**8. For incidents, always answer "why this time and not another time".** A root cause that
explains Tuesday but not why Wednesday was normal is not yet the root cause. The answer is often
**two conditions coinciding** — name both.

**9. Write for someone who is not inside your head.** A good QA report opens with a
*"How to read this report"* section — a table that translates terms into plain language: what a
"cache read" is, whether "0 reads" is good or bad. That section takes ten minutes and is why the
PO can read the report.

---

## Process

### Step 1 — Fix the question and the reader

Write down **exactly one question** the document will answer, and **who reads it**. The reader
sets the technical depth, not the writer's preference:

| Reader | Needs | Cut |
|---|---|---|
| External stakeholder (the client or sponsor) | conclusion, impact, what they must decide | class names, raw log lines, internal environment names |
| PO / tech lead | conclusion + trade-offs + open gaps | configuration details |
| Engineer in the team | enough to reproduce and verify | nothing, but there must be a glossary at the top |

If you cannot write that question yet, you do not understand enough to write the document.

### Step 2 — Load grounding and attach sources

Collect facts in the order **code > Jira > wiki**, and record the source at collection time,
not at writing time — recalling the source later is where errors creep in.

Every fact in the document must answer "how do we know this":
`repo/path/File.java:136` · `VUNG-<n>` · a Cloud Logging link with the time range set ·
a wiki page.

Reuse existing skills instead of building queries yourself: `ngvu-flow-logs` (logs chained
across the services), `ngvu-pod-health` (workload health), `ngvu-ticket-investigation`
(reading Jira and locating code).

When two sources conflict — the spec says one thing, the code does another — **that is a finding;
give it its own section**, do not silently pick the code.

### Step 3 — Build the document

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/new-report.sh <kind> <slug> --title "<title>"
# kind = incident | qa | onepager
```

The script creates a folder under `<workspace>\reports\<YYYY-MM-DD>-<kind>-<slug>\` (`<workspace>` = config `workspace`, default `D:\workspace`) with `report.html` (CSS,
theme toggle, verdict banner, log block, chips and Cloud Logging button already in place) and `NOTES.md` to
record raw evidence with its source while you work.

If the document belongs to a ticket under investigation, put it in that ticket's folder with `--into <path>`.

**Replace the content in the template, do not rewrite the CSS.** The template is verified in both
themes, has no sideways overflow, and renders correctly both locally and when published. The
structure of each block and when to use which: [references/report-anatomy.md](references/report-anatomy.md).

For a story/epic in Jira, do not use the HTML template — use the skeleton in
[references/quality-bar.md](references/quality-bar.md) (Today table, AC with trace codes,
"No regression" group, Out of scope section, Open questions with a default recommendation).

### Step 4 — QA gate before handoff

Run the automatic checks first, because they catch errors that do not show when you look at the
page in the light theme:

```bash
node ${CLAUDE_SKILL_DIR}/scripts/check-report.js <path>/report.html
```

It checks: tokens declared in all three theme blocks (a missing block breaks the theme — the
"white text on white background" bug), tabs match panels with exactly one tab selected, the tab bar
wraps instead of scrolling sideways, SVG `<marker>` ids are unique, all colours go through tokens,
unfilled placeholders, and **leftover full UUIDs or strings that look like tokens**. Exits with
code 1 on any error.

Then run the whole checklist in [references/qa-gate.md](references/qa-gate.md) — the part a human
must read. Three items may not be skipped:

- **Anonymise identifiers.** No copy (local or published) may still hold a real tenant id, not even the first 8 characters and not even inside a URL: replace it with
  `TENANT_REDACTED` or a label such as "tenant A". In examples use the fake id `00000000-0000-0000-0000-000000000000`. Never
  let through a token, `Authorization`, cookie, JWT, connection string, Vault path with its value,
  or client document content. Run `secret-data-guard` on the file before publishing.
- **Every link opens** and points to the time range that was actually used.
- **Every claim has a source** — go over it once more; for any sentence without a source, either
  add the source or downgrade it to a "hypothesis" and say so.

A published document cannot be taken back. This gate is mandatory, not optional.

### Step 5 — Handoff

**Default: hand over a local file, do not publish.** The deliverable is `report.html` in the
folder from Step 3 (`<workspace>\reports\...`, or the ticket folder if `--into` was used). Give the user the
absolute path. If the report belongs to a ticket, suggest pasting the `file:///...` link into
the user's own ticket notes.

Reason: the ngvu data policy forbids putting tenant data or secrets on an external service **or an Artifact**,
and an RCA or QA report almost always holds logs, tenant ids or client names. The local copy keeps
all the evidence for the team; a published copy must drop some of it.

**Publish as an Artifact only when all three of these hold:**
1. The user **explicitly asks to publish** this exact document, in this turn. Approving the
   content does not count as a request to publish, and an earlier consent cannot be reused.
2. What is published is **a separate file**, `report.public.html`, with every real tenant id, real
   client name, raw log and client document content removed.
3. `check-report.js` and `secret-data-guard` have run on **that exact file** and reported nothing.

```
Artifact(file_path="...\\report.public.html", icon="report", description="<one sentence>")
```

In the conversation, summarise: the **conclusion**, two or three pieces of evidence that support it, what is
**not** proven yet, and the next steps. Say clearly what could not be done instead of leaving the reader to find out.

If the document has a companion (such as a Report 1 / Report 2 pair on the same incident), publish both and
**insert cross-links at the top of each** — a reader arriving from one side must be able to find the other.

---

## When to split into two documents

Split when a topic has **two independent lines of analysis**, each long enough to stand alone — for example
"request load side" and "DNS infrastructure side". Sign that you should split: you find yourself writing two
unrelated recommendation sections.

When you split, each document must stand on its own: restate the shared conclusion at the top and say which
line this document covers. Do not make the reader combine two documents to understand the conclusion.

---

## Resources

| File | When to read |
|---|---|
| [references/quality-bar.md](references/quality-bar.md) | **Before writing, every time** — the quality bar with weak/strong examples side by side |
| [references/report-anatomy.md](references/report-anatomy.md) | When building an HTML document — each block and when to use it |
| [references/qa-gate.md](references/qa-gate.md) | Step 4, before every handoff |
| `assets/report-template.html` | Used by `new-report.sh`; read it if you want to change the skeleton |
| `scripts/new-report.sh` | Step 3 |
| `scripts/check-report.js` | Step 4 — run before every publish, and after every template change |

The presentation (app-bar + tabs + IBM Plex + categorical tokens kept apart from semantic ones) follows
`references/visual-style.md` of the `ngvu-ticket-investigation` skill (ngvu-factory plugin).
**Read that file before adding colour for a new repo or drawing a sequence diagram by hand** — it has the
light→dark mapping table and the coordinate rules; do not invent new hex values.

Related skills: `ai-output-evaluator` (self-review output before handoff), `secret-data-guard`
(Step 4), `incident-response` (handling an incident in progress — this skill writes it up afterwards),
`ngvu-ticket-investigation` (investigating a ticket, producing analysis documents).
