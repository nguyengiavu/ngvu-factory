# 02 — Current code analysis

> All evidence read directly from source on {{DATE}}.
> Notation: `repo/path/File.java:line`. Code not merged to master must name its branch.

---

## 1. System map — repos involved

<!-- Draw the flow in ASCII or mermaid. Goal: the reader understands who calls whom
     before reading each layer in detail. -->

| Repo | Branch examined | Merged to master? | Notes |
|---|---|---|---|

> Run `repo-inventory.sh` and `branch-status.sh` to fill this table. Do not guess.

---

## 2. Code area the ticket points to

### 2.1 File contents

| Line | Component | Notes |
|---|---|---|

### 2.2 Full call chain

<!-- From the entry point (UI / REST) down to the DB. The call chain shows
     "at which layer the needed data gets lost". -->

### 2.3 Problems found

### 2.4 Data that already exists but is not usable yet

<!-- Very common: what we need is already in the DB (audit column, parent entity, tracking
     table) but the DTO does not expose it. Finding this often turns a change that
     "needs a migration" into "just add one field". Always check:
       - does the entity extend AuditedEntity (created_date/updated_date)
       - does the service UPDATE or DELETE+INSERT (decides what created_date means)
       - which DTO drops fields of the entity -->

### 2.5 Other weak spots in this code area

| # | Problem | Evidence | Severity |
|---|---|---|---|

---

## 3. Related flows that already exist

<!-- A ticket rarely stands alone. Describe the flow of the Resolved sibling ticket
     that this ticket builds on: which table, which column, which status. -->

---

## 4. Injection point

<!-- Name the exact function/line to change. If a similar branch already exists
     (for example another blocking condition), say so to reuse its pattern. -->

---

## 5. Gap analysis

| # | Gap | Where | Required for the ticket? |
|---|---|---|---|
| G1 | | | |

---

## 6. Technical risks found while reading code

| # | Risk | Evidence | Mitigation |
|---|---|---|---|
| RS1 | | | |

<!-- Common risks in ngvu; check whether any apply:
     - One function shared by two different business flows (voluntary vs automatic)
       => the condition must be anchored to a table that tells the two flows apart
     - A service returns null for both "no data" and "technical error"
       => decide fail-open / fail-closed on purpose
     - The UI-side cache returns stale state
     - The gate exists only in the UI and can be bypassed through REST
     - The default readTimeout of 30s is too long for a UI action -->
