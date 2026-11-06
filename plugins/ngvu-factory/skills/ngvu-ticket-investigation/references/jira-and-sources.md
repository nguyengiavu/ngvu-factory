# Getting data from Jira / Confluence / GitHub

Jira: `https://example.atlassian.net/browse/<KEY>`

---

## 1. Order to try for reading Jira

These paths often break over time, so try them in order and **tell the user as soon
as you are stuck** instead of guessing the ticket content.

| # | Method | How to check | Notes |
|---|---|---|---|
| 1 | **Atlassian MCP connector** | try calling the tool `getJiraIssue`; or look for `mcp__*Atlassian*` in the tool list | Fastest, when the Atlassian MCP connector is configured |
| 1b | **Atlassian CLI `acli`** (installed via WinGet, OAuth login) | `acli jira auth status` → `✓ Authenticated` | Use when there is no MCP. Ticket: `acli jira workitem view VUNG-<n> --fields '*all' --json`. Epic children: `acli jira workitem search --jql 'parent = VUNG-<e> ORDER BY Rank ASC' --fields 'key,summary,status,issuetype' --limit 200 --json`. Read only; do not use write commands |
| 2 | **Claude in Chrome** | `tabs_context_mcp` | Uses the user's real Chrome session. If it says "not connected", the extension is not installed or not logged in |
| 3 | **In-app browser** (`mcp__Claude_Browser__*`) | `navigate` to the ticket, then `get_page_text` | Does **not** share cookies with Chrome: it redirects to `id.atlassian.com`. The user must log in **in the Browser pane** themselves (including the 2FA step). The pane is often hidden → remind them to open it |
| 4 | **Ask the user to paste the content** | — | Always available. Offer it in parallel with 2/3 so progress is not blocked |

**Never** type an email, password or 2FA code into a login form yourself. Ask the user to do it.

While you wait, do the work that **does not depend on the ticket**: survey the repos, read the
related code, read old `tasks/` folders. Do not sit and wait.

### Tips for reading a Jira page in a browser

```
navigate → wait 6-8s → get_page_text (max_chars 25000)
```

Jira pages render with JS; reading too early gives a blank page or the login page.
Group several tickets into one `browser_batch` to save calls:
`navigate A → wait → get_text → navigate B → wait → get_text`.

---

## 2. What to take from a ticket

Not only the description. These places often hold deciding information:

- **Acceptance Criteria** — if empty, that is a blocker, not a small detail
- **Comments** — release dates, scope changes, investigation results, tenant ids used for testing, SQL queries
- **Subtasks** + status — who is doing what, which parts are Resolved
- **Parent epic** — the epic description often holds all design decisions
  (numbered Q-1…Q-n, T-1…T-n) that the child ticket does not repeat
- **Sibling tickets in the same epic** — especially a **Resolved** ticket whose AC **contradicts** the current ticket
- **Development panel** — number of commits / PRs linked to the ticket
- **Attachments** — images; the text around an image usually says enough, but if the
  analysis depends on an image, say clearly that you could not view it

---

## 3. Signs a ticket is not ready to code

If you see any of these signs, state it in the documents right away. Do not quietly guess:

- Acceptance Criteria are empty
- The user story is **copied word for word** from another ticket (common with AI-generated
  tickets — see the label `ai-generated`); the really new part is often only in the *Context* section
- No Assignee, no Story Points, no Sprint
- Contradicts the AC of a Resolved ticket
- A date constraint exists only in a comment, not in the Fix Version

---

## 4. GitHub

Remote: `https://github.com/nguyengiavu/<repo>.git`

Local git usually has cached credentials, so `git ls-remote` works without another login.
This is the cheapest way to know whether a ticket already has a branch:

```bash
scripts/scan-ticket-refs.sh <ticket-number>
```

Branch naming by team: `ngvu/...` (this team), `team-b/...`, `team-d/...`, `team-c/...`.
Epic branches often look like `ngvu/vung-<epic>/vung-<story>-<description>`.

---

## 5. GCP

`gcloud`, `gsutil`, `bq` are on the PATH. Use them to read Cloud Logging logs when you need to
investigate a runtime incident. Most design-investigation tickets do not need them.

---

## 6. Writing back to Jira

Writing to Jira is an **external action**: ask the user first, even when the content
was already approved in the conversation. Things you are often asked to do after the investigation:

- Paste the proposed Acceptance Criteria into the ticket
- Fill the subtask *Investigate, find solution* with a link to the documents folder
- Add a note "superseded by VUNG-xxxxx" to the AC of the old ticket that was replaced
