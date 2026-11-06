# 01 — Epic & Context

> Fill this file **before reading code**. Sources: `evidence/E0-jira-inventory.md` (from `epic-children.sh`) and
> `evidence/E1-jira-epic-verbatim.md` (the epic's description, AC and comments, verbatim).

## 1. {{EPIC}} — facts about the epic itself

| Field | Value |
|---|---|
| Status / Assignee / Sprint / Fix Version | |
| Number of child tickets (by type × status) | |
| Links, attachments, design pages (e.g. Confluence) | |

## 2. Actual requirements (R-list)

<!-- Each R is a verifiable statement, with its basis quoted verbatim. Tag [AC#] = an AC of the epic,
     [sibling] = an implicit requirement from a sibling ticket/the other system. breakdown.sh reads the "| R<n> |" rows
     of this section to check coverage: every R must be Covered by at least one story. -->

| # | Requirement | Basis (verbatim quote) |
|---|---|---|
| R1 | | |

## 3. Testability of the epic's AC

| AC | Testable? (✅ / ⚠️ / ❌) | What is missing to make it testable |
|---|---|---|
| AC1 | | |

**AC conclusion:** <!-- x/y testable now; enough to cut stories yet? -->

## 4. Ticket map (read from Jira, {{DATE}})

<!-- Every child ticket in E0 has a row here. Add tickets outside the epic that are linked or mentioned in comments. -->

| Ticket | Type / Status | Role in the epic | Notes (AC contradicts? copied story? Resolved?) |
|---|---|---|---|
| | | | |

## 5. Verified conflicts & gaps

<!-- Each C-n quotes both sources side by side, is marked 🔴 (blocking) / 🟠 / 🟡, and names who owns the decision.
     Do not "reconcile" silently: pick the default in 12, not here. -->

### C1 — <title> 🔴

## 6. Release / schedule constraints

<!-- Usually only in comments: dates, the sprint of a dependent ticket, freezes. -->

## 7. Not done / not read yet
