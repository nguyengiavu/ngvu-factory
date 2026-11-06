# 07 — Roadmap & Definition of Done

> Baseline date: {{DATE}}.
> Release constraint: <!-- quote verbatim from the Jira comment if there is one -->

---

## 1. Schedule assumptions

<!-- State clearly what is an assumption and who must confirm it. A roadmap built on guessed
     dates that does not say they are guesses will be read as a commitment. -->

| Assumption | Value used for planning | Needs confirmation from |
|---|---|---|

---

## 2. Weekly roadmap

| Week | Dates | Item | Output | Blocked by |
|---|---|---|---|---|
| W1 | | | | |

```mermaid
gantt
    title Roadmap {{TICKET}}
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m
    section Preparation
    ...  :crit, a1, {{DATE}}, 3d
```

<!-- Mermaid gantt breaks on accented letters in task names in some renderers;
     write task names without diacritics. -->

---

## 3. Milestones & gate criteria

| # | Milestone | Target date | Gate criteria |
|---|---|---|---|
| M0 | Definition of Ready | | |

---

## 4. Schedule risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|

<!-- The number one risk in ngvu is a dependency on a PR in another team's repo.
     The most effective mitigation: write the code for them, so they only have to review it. -->

---

## 5. Definition of Done

### Code
- [ ] PR merged into the right base branch
- [ ] No unplanned migration added
- [ ] Sonar clean
- [ ] No sensitive data logged

### Test
- [ ] Decision table passes
- [ ] Decisive E2E scenario passes
- [ ] Regression clean
- [ ] Perf meets the threshold

### Operations
- [ ] Feature flag present in every env
- [ ] Metrics + alerts configured
- [ ] Rollback rehearsed
- [ ] Support has a runbook

### Jira
- [ ] AC filled in
- [ ] Assignee + Story Points set
- [ ] Investigate / Self-check / Cross-check subtasks closed
- [ ] This document linked in the ticket
- [ ] Extra scope added to the epic's test ticket

---

## 6. Who does what

| Role | Person / team | Responsibility |
|---|---|---|
