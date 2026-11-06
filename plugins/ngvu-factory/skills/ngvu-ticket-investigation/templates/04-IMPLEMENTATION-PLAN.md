# 04 — Implementation plan

> Chosen option: see [03-OPTIONS-EVALUATION.md](03-OPTIONS-EVALUATION.md) §7.
> Total estimate: ? person-days.

---

## 1. Step 0 — Acceptance Criteria

<!-- If the AC on Jira is empty or vague, write a proposal here for the PO to paste in.
     AC must be testable GIVEN/WHEN/THEN, and each AC must map to at least
     one test case in 05-TEST-PLAN.md. -->

```
GIVEN ...

AC-1  WHEN ...
      THEN ...

AC-2  ...
```

---

## 2. PR-1 — `<repo>` <!-- say so if the repo belongs to another team: that is the critical path -->

**Branch:** `...` (base: `...`) <!-- wrong base = half a day resolving conflicts; confirm with branch-status.sh -->

### Changes

| File | Change |
|---|---|

### Important technical details

<!-- For what the diff does not show: why the code sits in this layer and not
     another, which entity is @Embeddable and so has no audit column,
     which branch of the function gives a wrong result if done the obvious way. -->

### Backward compatibility

<!-- For DTO/API changes: list each consumer and the fields it declares.
     The best evidence is "consumer X ignores field Y and still runs in production". -->

**Estimate:** ? dev days + ? days waiting for review

---

## 3. PR-2 — `<repo>`

<!-- repeat the structure -->

---

## 6. Order of work & dependencies

```mermaid
graph LR
  A["Step 0"] --> B["..."]
```

**Critical path:**
**Can run in parallel:**

---

## 7. Feature flag

<!-- For a change that touches every customer's flow, a flag lets you deploy early and enable late.
     Split the "enabled" flag from the "enforcing" flag to allow shadow mode: measure the real
     impact on production before actually blocking or changing behaviour. -->

| Flag | Default | Effect |
|---|---|---|

---

## 8. Overall estimate

| Item | Estimate | Dependency |
|---|---|---|
| **Total dev** | | |
| **Total calendar** | | |

---

## 9. Definition of Ready

- [ ] AC approved by the PO
- [ ] Conflicts with sibling tickets resolved
- [ ] Teams owning other repos confirmed scope + timeline
- [ ] Blocking questions in [08-OPEN-QUESTIONS.md](08-OPEN-QUESTIONS.md) settled
- [ ] Base branch confirmed with `branch-status.sh`
- [ ] Story Points + Assignee + Sprint set
