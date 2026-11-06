---
name: ngvu-ticket-investigation
description: "Default entry point for one VUNG ticket (ngvu): read the ticket + epic, read code across repos, score options with file:line evidence, generate the folder <tasks>/VUNG-number-slug (9 .md files + a presentation). Use when there is a VUNG-xxxxxx key or an example.atlassian.net link, or to investigate, estimate, plan or write a spec for a ticket. Epics use ngvu-epic-investigation. Build next with /ngvu-factory:ngvu-factory ticket."
---

# Investigate a VUNG ticket (ngvu)

This skill turns a ticket key into a folder of documents that the PO, the tech lead and the
implementer can all use, and can reuse six months later when nobody remembers the context.

The value is in the **evidence**, not the length. A sentence like "this part is not optimal" without
a `file:line` and a concrete failure scenario does not help anyone decide anything.

---

## Fixed conventions

Every investigated ticket has exactly one folder:

```
<tasks>\VUNG-<number>-<slug-kebab>\  <tasks> = config paths.tasks (default D:\workspace\tasks; scripts/workspace.sh)
├── README.md                      executive summary + table of contents
├── 01-TICKET-AND-CONTEXT.md       Jira verbatim, epic, contradictions, release constraints
├── 02-CODE-ANALYSIS.md            code reading, file:line evidence, gaps, risks
├── 03-OPTIONS-EVALUATION.md       options, scores, recommendation
├── 04-IMPLEMENTATION-PLAN.md      proposed AC, PRs per file, feature flag
├── 05-TEST-PLAN.md                unit / IT / E2E / regression / perf
├── 06-DEPLOY-AND-TEST-DATA.md     pipeline, environments, SQL seed, rollback
├── 07-ROADMAP-AND-DOD.md          roadmap, milestones, Definition of Done
├── 08-OPEN-QUESTIONS.md           questions with a default recommendation
└── diagrams\
    ├── WORKFLOW.md                Mermaid diagrams
    ├── presentation.html          presentation in reportLanguage
    └── presentation.en.html       English translation (only when reportLanguage is not en)
```

Keep the file names and the numbering. This consistency is why others find information
without reading the whole folder, and why you can compare two tickets side by side.

The slug is 2-4 words that describe the **content**, not the type of work: `resubscribe-card-revalidation`
is better than `investigation` or `story`.

### Report language

Read `reportLanguage` from the machine config `~/.claude/ngvu-factory/machine.json`
(default `en` when the key or the file is absent; for example `vi` writes Vietnamese).
Section headings and file names in the templates stay English: they are a fixed structure that
scripts and checks rely on. The prose you write inside them is in `reportLanguage`.

---

## Process

### Step 1 — Build the skeleton first, so no section is forgotten

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/new-task.sh <number> <slug> --title "<short title>"
```

The script creates the folder from the templates and refuses to overwrite an existing folder.

### Step 2 — Read Jira

If the ticket's issuetype is **Epic**, use the skill `ngvu-epic-investigation`
instead of this one (folder `EPIC-VUNG-<number>-<slug>`, story breakdown for `/ngvu-factory:ngvu-factory epic`).

**Child ticket of an investigated epic** (`<tasks>\EPIC-VUNG-<epic>-*` exists): read the epic's `README`, `01` (R-list,
contradictions C-n), `08` (this ticket's row in `## Factory queue` and its `### S<n>` section) and `12`
**before** filling the ticket's `01`. Write in `01` §3: the link to the epic folder, the story key `S<n>`, the R items the story
Covers, the AC keys `AC-S<n>-…`. Point to the epic instead of copying its context; write only what is specific to the ticket.
If there is no epic folder yet, investigate as usual and write "epic not investigated yet" in `01` §3.

Read the ticket, the **parent epic**, and every related sibling ticket. See
[references/jira-and-sources.md](references/jira-and-sources.md) for the order of access methods
(MCP → `acli` → Chrome extension → in-app browser → ask the user to paste) and the list of places
that hold deciding information outside the description.

Three things to check at once, because they decide whether the ticket can be done:

1. **Are the Acceptance Criteria empty?** Empty is a blocker, not a small detail.
2. **Was the user story copied from another ticket?** Common with tickets labelled
   `ai-generated`. If so, the truly new part is usually only in the *Context* section;
   say that plainly and point out which part is new.
3. **Is there a Resolved sibling ticket whose AC says the opposite?** This is the most expensive
   thing to miss: the cross-check fails and you have to go back to a PO meeting.

Fill `01-TICKET-AND-CONTEXT.md` **before reading code**. Reading code before you know the requirement
makes you read aimlessly and find what you want to find.

If Jira is not reachable: tell the user at once, ask them to paste the content, and **keep working
on what does not depend on the ticket** (repo survey, reading the related code). Do not sit and wait.

### Step 3 — Locate the code before reading it

```bash
bash .../scripts/repo-inventory.sh <keyword>       # which repos exist, which branch they are on
bash .../scripts/scan-ticket-refs.sh <number>      # does the ticket already have commits/branches anywhere
bash .../scripts/branch-status.sh <repo-path> <branch>  # is that branch merged into master
```

This step is short, but skipping it is the number one cause of wrong analysis: epic code
often sits on a branch **not merged into master**, and reading master leads to the conclusion "nobody has done anything".

If scanning by the ticket number finds nothing, scan again by the **parent epic** number.

### Step 4 — Read code and record evidence

Read from the entry point (REST endpoint / UI handler) down to the DB. The full call chain is what
helps you find "at which layer the data I need gets lost".

Every claim in `02-CODE-ANALYSIS.md` must point to `repo/path/File.java:line`.
For code on an unmerged branch, name the branch.

Before concluding, go through [references/pitfalls.md](references/pitfalls.md):
recurring traps that lead to wrong conclusions, with how to detect them. Worth reading every time, not only the first time.

Always ask two questions, because the right answer often makes the ticket one level cheaper:

- **Is the data I need already in the DB but not exposed yet?** Check
  `extends AuditedEntity` (audit columns), check whether the service writes with UPDATE or DELETE+INSERT,
  check which internal endpoint already returns the raw entity.
- **Does the system already have an enum/taxonomy that classifies this problem?** It tells you at once
  how much of the real cases the condition you plan to write covers.

### Step 5 — Propose options and score them

First split the problem into independent **design axes**; each option is then a combination of
choices on those axes. This avoids comparing apples with oranges and lets you build hybrid options.

Score on 6 criteria: business correctness · cost · bypass resistance · testability · operations · risk.

For each option, the **"not optimal"** part must be concrete enough for someone else to verify:
an enum name, a real user scenario, a line of code. "Hard to maintain" is not evidence.

Also state **what not to do** and why: that section saves the next person exactly the hours
you spent ruling those options out.

State the trade-off of the option you recommend. A recommendation with no downside
is a sign you have not thought deeply enough.

### Step 6 — Plan, test, deploy, roadmap

Fill `04` → `07`. Points that are often done superficially:

- **Base branch of each PR**: confirm it with `branch-status.sh`; do not assume master.
- **PR in another team's repo**: mark it as the critical path and put it in the first week.
  The most effective way to reduce the risk: write the code for them, so they only need to review.
- **Feature flag**: separate `enabled` from `enforcing` so shadow mode can run
  (measure the real impact on production before changing behaviour). For a change that touches the flow
  of every customer, this is the difference between "5-minute rollback" and "incident".
- **Deciding E2E scenario**: the scenario that fails if the wrong option is implemented.
  Mark it clearly; it is the most valuable test in the whole plan.
- **E2E harness** (code, `node_modules`, traces, videos) goes in `<workspace>\.e2e\VUNG-<number>\`; the login session
  (`auth.json`) goes in `%LOCALAPPDATA%\ngvu-e2e\VUNG-<number>\`, never in `tasks\` (rule
  *Browser sessions & E2E harnesses* in `data-protection-policy.md`). The task folder keeps only a README on how to run it,
  screenshots, logs, the HTML report and an evidence index.
- **How to trigger a cronjob by hand**: many ngvu flows only run on the 10th/20th/first of the month.
- **Release constraints** often appear only in Jira comments, not in the Fix Version.

Every open question must come with a **default recommendation**: if nobody objects, go with it.
A question without a recommendation only pushes the thinking to the PO and slows the ticket down.

**Before writing the AC and the story description**, read
`references/quality-bar.md` of the skill `ngvu-evidence-report` (plugin `ngvu-engineering`).
The four techniques there clearly raise story quality, taken from well-formed, approved user stories:
**the "Today" table** (each sub-behaviour × `Exists`/`Partial`/`Missing` with evidence: turns a vague
requirement into a countable delta), **separating effort from scope**, **AC with trace keys plus a
"No regression" group**, and **writing traps as symptom chains** instead of code smells.

### Step 7 — Diagrams and presentation

`diagrams/WORKFLOW.md` holds plain Mermaid diagrams (for places that do not render HTML,
for example a Jira comment). Each diagram must answer **one specific question**; a diagram
that answers no question only makes the document longer.

`diagrams/presentation.html` is the main presentation, a real "web app" page:
a sticky app-bar + a wrapping tab bar (each tab is one separate "slide", see the structure in the comment
at the start of the template's `<body>`), a **light/dark theme toggle** in the app-bar, sequence diagrams
**drawn by hand in SVG** in the page's colour language (each repo has a fixed hue, arrows are coloured by
*meaning*, not by lane), and Mermaid only for flowchart/gantt (lazy-loaded, fetched only when
the user opens a tab that needs it). All of it is verified: both themes, no horizontal overflow, no breakage when
opened as a local file or published as an Artifact. Replace the **content**; do not rewrite the CSS/script.

**`presentation.html` is written in `reportLanguage`. Only when `reportLanguage` is not `en`, also write
`presentation.en.html`.** Reviews and presentations at ngvu are cross-team (other teams, the client),
so people who do not read the report language must still be able to open the presentation. The en version is a
translation of the **finished** `presentation.html`:
- Copy the whole file, then replace only the text the reader sees: `<title>` (add ` (EN)` so the two Artifacts
  can be told apart in the gallery), app-bar, tab labels, headings, paragraphs, tables, `figcaption`, `<text>` in SVG, every
  `aria-label`, Mermaid labels, and the two UI strings in the script (`themeLabel`: `Light`/`Dark`;
  `aria-label` of `#themeToggle`). CSS, script, tab structure and SVG coordinates stay unchanged.
- Keep verbatim: class/method/column names, `file:line`, error codes, SQL, figures, and Jira quotes (already in English).
- English text is often longer: check that arrow labels in the SVG still fit between two lifelines (11.5px mono ≈ 7px/char).
- The nine `.md` files stay in `reportLanguage`; only the presentation gets an extra en version.
- When you edit `presentation.html`, edit `presentation.en.html` in the same turn and publish both again, so the two never drift apart.

**Layout & theme: three lessons learned, do not repeat them:**
- A page that only follows the host's theme is **not enough**. Users reported "there is no dark/light
  mode" when the page followed the host without a toggle: they could not see the feature existed.
  The template already has `#themeToggle`; **keep it**.
- Hand-drawn SVG changes colour at once because it uses `var(--token)`, but **Mermaid bakes colours into the SVG at
  render time**. The template script already handles this: it stores the original source in `data-src` and rebuilds the open
  panel when the theme changes. If you edit the script, do not lose that step.
- **The tab bar wraps (`flex-wrap`), it does not scroll horizontally.** Artifacts render in a panel narrower than the
  browser window (~1000px), so horizontal scrolling hides the last tabs with no visible sign. Do not
  "fix" it by shortening labels to fit 1440px: that measures the wrong place.

**Read [references/visual-style.md](references/visual-style.md) before you:**
- add a new repo/system that needs its own categorical colour (colour assignment process + light→dark
  lookup table are there, do not invent new hex values),
- draw another sequence diagram by hand (coordinate formula, arrow colour by meaning,
  the duplicate `<marker>` id trap across several SVGs on the same page),
- touch the theme, the tab bar layout, or merge several outcomes into one diagram (the `band` pattern).

Before publishing, run `secret-data-guard` on `presentation.html` (and `presentation.en.html` when it exists) and the 9 .md files:
real tenant ids, emails, tokens, SQL with customer data copied from Jira must be replaced by placeholders
(`TENANT_REDACTED`, `PII_REDACTED`…). Once clean, publish each presentation file as **its own Artifact** (two files → two URLs),
so the user has a link to share with each group of readers:

```
Artifact(file_path="<tasks>\\VUNG-<number>-<slug>\\diagrams\\presentation.html",
         icon="<one word, for example ticket>", description="<one sentence in English>")
Artifact(file_path="<tasks>\\VUNG-<number>-<slug>\\diagrams\\presentation.en.html",   # only when reportLanguage is not en
         icon="<same word>", description="<one sentence in English>")
```

Write every link in the task folder's `README.md`.

Load the skill `artifact-design` (and `artifact-diagramming` if you draw SVG by hand) before making
significant changes to the presentation. Check with `javascript_tool` reading `getComputedStyle` (also after
setting `data-theme="dark"`), do not only trust screenshots: the pane treats a local file outside the project
as a "static snapshot", so screenshots do not reflect new interaction/theme correctly.

### Step 7b — Report back to the epic (only when an epic folder exists)

Compare with the epic's `08`/`12` and list what this ticket found to be different: new repo, new blocker, new question,
an R or AC that no longer holds. Write the list in the ticket's `README` §3 (Warnings before coding), under a sub-heading "Differences from the epic", and **ask the user first** before editing
the epic's `08`/`12`. After editing, run the epic's `breakdown.sh` until it exits 0. A new repo needs an epic branch
→ remind the user to run `/ngvu-factory:ngvu-factory epic vung-<epic>` again (it creates the epic branch for that repo).
**Done when:** the list of differences is written (or "none" is written), and the epic is updated or the user has decided not to update it.

### Step 8 — Report back

In the conversation, say briefly: what the ticket really asks for, the 3-5 most important findings,
the recommendation, and **the questions the user must decide**. Include the Artifact link of each presentation and the folder path.
Once the user settles on an option, the next build step is `/ngvu-factory:ngvu-factory ticket VUNG-<number>` (it reads this task
folder as input).

State clearly what was **not** done (Jira images not viewed, module not available locally) instead of
leaving the reader to discover it.

Writing to Jira is an external action: **ask first**, even when the content has been agreed.

---

## Right size

Not every ticket needs all 9 files. For a small ticket, merge `05`–`07` into `04` and
say in `README.md` that they were merged. What you must never drop, however small the ticket:

- `01`: if the AC is empty or contradictory, it must be found at once
- `02`: a conclusion without evidence cannot be reused
- `08`: unsettled questions are what make a ticket miss its deadline

---

## Resources

| File | When to read |
|---|---|
| [references/jira-and-sources.md](references/jira-and-sources.md) | Jira not reachable; need to know what to take from the ticket |
| [references/pitfalls.md](references/pitfalls.md) | **Before concluding the analysis, every time** |
| [references/visual-style.md](references/visual-style.md) | Before adding a new repo/colour or drawing another sequence diagram by hand in `presentation.html` |
| `templates/` | Used by `new-task.sh`; read if you want to change the skeleton |
| `scripts/new-task.sh` | Step 1 |
| `scripts/repo-inventory.sh` | Step 3: which repos exist, which branch |
| `scripts/scan-ticket-refs.sh` | Step 3: where the ticket already has code |
| `scripts/branch-status.sh` | Step 3 and before creating a new branch |
