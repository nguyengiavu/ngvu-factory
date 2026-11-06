# QA gate before handoff

Run this whole checklist **before** giving the document to anyone — even when it only goes inside
the team. A published document cannot be taken back, and an Artifact with a share link can be
**viewed by anyone who has the link**.

The order below is the order to run it in: start with what causes irreversible harm.

---

## A. Sensitive data — do not skip any item

| Check | How to handle |
|---|---|
| Real tenant id | Replace with `TENANT_REDACTED` or a label ("tenant A") everywhere, including Cloud Logging URLs (`rules/data-protection-policy.md`). |
| Ids used in examples / fixtures | Use a clearly fake id: `00000000-0000-0000-0000-000000000000`. Do not copy a real id from a log as an example. |
| Token, `Authorization`, cookie, session, JWT | Remove completely. No "it is only a dev token" exception. |
| Password, connection string, service key | Remove completely. |
| Vault path | You may give the **path**, never the **value**. |
| Client document content / personal data | Do not quote it. Describe it in words, or replace it with fake data. |
| Raw request/response payload | Trim and clean it before pasting. Do not paste the whole block. |
| Screenshot | Look closely — client or tenant names, emails and account numbers often slip in at the edge of the screen. |

Run `secret-data-guard` on the file before publishing. If that skill reports anything, fix it
before you go on.

**If you find a leaked secret in the repo or in notes:** report its **location and type** (`file:line`,
"plaintext password"), never the value, and recommend key rotation + removal.
Do not use that information to continue the work, even when it would finish the task faster.

---

## B. Evidence

- [ ] Every material claim has a source: `file:line` · ticket key · log link · wiki page name.
- [ ] **Click every link** — a Cloud Logging link must open, and its time range must match the
      actual run, not a wide range for convenience.
- [ ] Numbers are shown as a **distribution**, not only a total.
- [ ] For any sentence without a source, either add the source or **downgrade it to a hypothesis** and
      say that it is a hypothesis.
- [ ] Confidence is marked where things are not certain (`inference` / `hypothesis` / `unknown`).
- [ ] There is at least one sentence about **what this document has not proven**.

---

## C. Reader

- [ ] The document opens with the **conclusion**, visible without scrolling.
- [ ] If the reader is an external stakeholder: class names, internal environment names and raw log lines are cut.
- [ ] If the reader is an engineer: there is a glossary at the top that explains terms and **says which numbers are
      a good sign** (for example "0 reads is a sign of success").
- [ ] No internal abbreviation appears for the first time without an explanation in brackets.
- [ ] The title is a statement or a question, not a label.

---

## D. HTML page

- [ ] Open it in **both themes** (light and dark) — text does not sink into the background, charts stay readable.
- [ ] No sideways scroll in a narrow frame. Tables and log blocks scroll **inside their own frame**.
- [ ] Every external link opens a new tab.
- [ ] There is a properly named `<title>` — it is the display name in the Artifact gallery.
- [ ] Open it at a narrow width (~1000px), because an Artifact renders in a panel narrower than the browser window.

---

## E. Before you press publish (only when the user asks to publish)

- [ ] The default is **do not publish**: hand over the local file (SKILL.md, Step 5).
- [ ] **The user has explicitly asked to publish** this exact document, in this turn.
- [ ] What is published is the separate file `report.public.html`: no real tenant id left (not even the first 8
      characters), no real client or tenant name, no raw logs. `check-report.js` and `secret-data-guard` have
      run on that exact file and reported nothing.
- [ ] If the document is part of a multi-part set: cross-links are inserted at the top of **each copy**.
- [ ] The conversation records: the conclusion, the main evidence, what could not be done, the next steps.
- [ ] If you plan to write back to Jira or a wiki — **ask again, separately**. That is a different action
      from publishing an Artifact.
