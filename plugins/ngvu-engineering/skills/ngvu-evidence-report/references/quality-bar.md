# Quality bar — learn by comparison

Distilled from approved deliverables: incident reports, a QA report on a cache change, and a Jira story
written clearly enough for an agent to carry it out (labelled `ai-ready`).

How to use this file: before writing, skim the headings. After writing, go back and check each section
as a checklist. Most of the difference between a fair document and a good one lies in the places below.

**Contents**
1. [Title](#1-title)
2. [Opening — verdict first, details after](#2-opening)
3. [Current state before the work to do](#3-the-today-table)
4. [Traps written as a symptom chain](#4-symptom-chain)
5. [Evidence and sources](#5-evidence-and-sources)
6. [Honesty about limits](#6-honesty-about-limits)
7. [Acceptance criteria](#7-acceptance-criteria)
8. [Open questions and scope](#8-open-questions-and-scope)
9. [Signs a document is not there yet](#9-signs-it-is-not-there-yet)

---

## 1. Title

The title decides whether people read on, and it is the only thing remembered after three months.

| | Example | Why |
|---|---|---|
| ❌ Label | "MongoDB incident analysis of 08/09" | Says only *what it is about*, not *what it concludes*. The reader still has to open it to find out. |
| ✅ Statement | "The morning MongoDB timeouts are a DNS incident — **not** database overload" | Also names what was ruled out. Anyone who suspected the database knows at once where they were wrong. |
| ✅ Question | "Does the gate call Mongo only on the first request?" | Turns the document into a verifiable answer. Suits QA reports. |

Tip: if your title would also fit another document of the same kind, it is a label, not yet a title.

---

## 2. Opening

The first reader is often someone who must decide within thirty seconds and will not scroll down.

The first three lines must hold:

1. **Verdict** — `3 / 3 PASS`, or "root cause: DNS", or "no conclusion yet, need X".
2. **One sentence that explains that verdict in plain language**, without internal terms.
3. **Where the evidence is** — "example-docs logs + the Cloud Logging links below".

Add the context strip: environment · build/commit · component · date · method. This strip lets you know,
six months later, which version the document is about.

If the document is part of a multi-part set, say at the top **which line this document covers** and insert
a link to the other one. A reader arriving from one side must be able to find the other side.

---

## 3. The "Today" table

This is the strongest technique in the team's good stories, and it works for reports as well as for
option analyses.

Before saying *what to do*, list **each sub-behaviour** and its **current state**:

| Part of the flow | Today |
|---|---|
| Upload, ZIP check, background unzip | **Exists** — `DocsImportValidator`, `FileUtil.unzip` |
| Folder tree recreated 1:1 | **Exists** |
| Detect and pair metadata files | **Missing** — every entry that is not a folder becomes a document, so `.metadata.json` is imported as a separate document |
| Skip operating-system junk | **Partial** — `isExcludedFile` only skips names that start with a dot, so `Thumbs.db` still gets through |

The three states `Exists / Partial / Missing` with **concrete evidence** do three things at once:
turn a vague request into a countable delta, prevent over-estimating what already exists, and give the reviewer
something to push back on.

For `Partial`, always say **exactly what is missing** — "only skips names that start with a dot" is useful;
"not complete" is not.

### Separate effort from scope

Right after the Today table, if most of it already exists, write it out:

> *"Most of the path is already built, so in practice this is a delta, not a new
> service. That affects the **effort**, not the **scope** of the work or
> what must be proven to close it."*

Mixing the two is the most common way a piece of work gets closed too early: "the code is already there" becomes
the reason to skip the proof.

---

## 4. Symptom chain

Do not describe a trap in the language of code. Describe it by **what people will see when it fires**.

| | How to write it |
|---|---|
| ❌ Code smell | "`getUnprocessFile` does not handle the file list correctly." |
| ✅ Symptom chain | "If metadata is not excluded in `getUnprocessFile` → the unprocessed list **never drains** → the job **looks hung forever** → the system finally **invents a TIMEOUT error for a transfer that actually succeeded**." |

A symptom chain has three parts: trigger condition → how it spreads → **the symptom the operator
sees**. The last part is what the reader remembers, because it is what they once met at two in the morning.

A second example of the same kind:

> *"`FileUtil.extractAllZipFile` swallows unzip errors — logs SEVERE and returns — so a
> truncated `transfer.zip` produces **a silent partially successful import**, instead of
> a reported error. Worth deciding explicitly whether that is acceptable for a
> system-to-system flow, where the sender expects a definite result."*

Note the last sentence: it **does not decide on its own**, but raises the issue as a decision someone owns.
That is the right way to handle something outside your own authority.

---

## 5. Evidence and sources

Source priority: **`code > Jira > wiki`**. On conflict, code wins — but
**the conflict is a finding and must get its own section**; do not silently pick a side. In
many documents this is the most valuable part.

Every claim must answer "how do we know this":

- Code → `repo/path/File.java:136` (if on an unmerged branch, name the branch)
- Ticket → `VUNG-<n>`
- Log → a **link that opens**, with the filter and the time range of the actual run already set
- Wiki → the page name, not "according to the docs"

Record the source **at collection time**, not at writing time. Recalling the source later is where errors creep in.

### Presenting numbers

Do not give only a total. Give the **distribution**, because only the distribution answers the question.

| | Example |
|---|---|
| ❌ | "3 requests caused 2 Mongo reads." |
| ✅ | "2 reads on req#1 → **0 on req#2 and req#3**." |

A total does not tell whether the cache hits; the distribution does. Likewise, "≈6 reads before the fix,
≤2 after the fix" is stronger than "a significant drop".

---

## 6. Honesty about limits

This is what separates a trustworthy document from one that only sounds good.

**State what you could not prove.** A pattern worth learning from: three test cases fired requests forty
seconds apart, which is well within the first-tier cache lifetime (300 seconds). The writer spotted that this
means **the experiment cannot tell an in-pod cache from a shared cache** — and designed an extra
case that waits 330 seconds to close exactly that gap.

Finding the gap in your own evidence and closing it is the clearest sign of a trustworthy document.
If you could not close it, you must still state it.

**Record rejected hypotheses.** If you first suspected MongoDB ran out of memory and the evidence ruled that out,
write down the whole path as a section "two hypotheses — only one survives". The next reader will
suspect exactly what you suspected; dropping this section makes them walk the path you already walked.

**Separate levels of confidence.** Not every sentence is equally certain. Mark them clearly:
`verified` · `strong inference` · `hypothesis` · `unknown`. A document where every sentence is stated with
full certainty is a document that has not been reviewed.

**For incidents, always answer "why this time and not another time".** A root cause that
explains Tuesday but not why Wednesday was normal is not yet the root
cause. The answer is often **two conditions that must coincide** — name both, and say what happens
if only one is present.

---

## 7. Acceptance criteria

Applies to stories, and to the pass criteria in QA reports.

**Write them as observable outcomes**, not as tasks:

| | Example |
|---|---|
| ❌ | "Handle broken metadata files." |
| ✅ | "A metadata file with no matching document **is rejected and reported as an error for that entry only; the rest of the transfer continues**." |

**Attach trace codes.** Each criterion points to a business rule: `(BR-01)`, `(BRule-5)`. That way,
when a rule changes, you find every affected criterion at once.

**Thresholds must be countable.** "≤2 cache reads per 3 requests", not "the cache works well".

**Always have a "No regression" group.** Name the old behaviour that must not break: *"A ZIP with no
metadata file at all — that is, today's myLife upload flow — produces exactly the same result as today."*
This group is often forgotten and is a source of incidents after release.

**A negative instruction must carry its reason.** *"This behaviour is **deliberately** lenient. Do not add schema
validation."* Without the word "deliberately" and the reason, the next person will "fix" it.

---

## 8. Open questions and scope

**The "Out of scope" section names what belongs to other work.** "Storing and returning healthData; job
report semantics. Both are separate stories in this epic." Without this section, the scope drifts while you work.

**Every open question must carry a default recommendation** — if nobody objects, go ahead with it. A bare
question only pushes the thinking onto someone else and slows the work down.

Put open questions **before** the plan, not at the end. They decide whether the plan
holds up.

---

## 9. Signs it is not there yet

Go over the document and look for these signs. Fix each one you find.

- The title would fit another document of the same kind → the title is a label.
- You must scroll more than one screen to see the conclusion.
- A sentence says "according to the logs…" without a link that opens.
- Every sentence is stated as certain; none is marked as a hypothesis.
- No section covers what is not proven.
- A trap is named by function name without the consequence users see.
- A total is given instead of a distribution.
- An open question has no recommendation.
- No "No regression" group (for a story).
- A real tenant id, token or client content is still in a document about to be published.
- The target reader is an external stakeholder but the document is still full of class names and internal environment names.
