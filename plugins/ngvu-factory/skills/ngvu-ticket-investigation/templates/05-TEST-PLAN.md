# 05 — Test Plan

> Stack: JUnit 4.13.2 + Mockito + Arquillian. surefire (`-DskipUTs`) for unit tests,
> failsafe (`-DskipITs`) for `*IT.java`. Default for `services/` repos; check each repo's pom.

---

## 1. Test matrix by Acceptance Criteria

<!-- Each AC needs at least one ✅ cell. An AC without a test will not be verified
     in the cross-check. -->

| AC | Unit | IT | E2E | UAT | Perf |
|---|:--:|:--:|:--:|:--:|:--:|
| AC-1 | | | | | |

---

## 2. Unit test

### 2.1 `<repo>`

| Test class | Case |
|---|---|

### Decision table

<!-- For logic with many conditions, a full decision table beats a list of separate
     tests: it shows at once which combination is missing. -->

| # | Condition 1 | Condition 2 | ... | Expected |
|---|---|---|---|---|
| 1 | | | | |

### Edge cases to test separately

<!-- Date/month parsing, empty string, null, unparseable values, time zone offsets. -->

| Input | Expected |
|---|---|

---

## 3. Integration test

| Test | Content |
|---|---|

---

## 4. E2E scenarios

<!-- Number them E2E-1, E2E-2... and clearly mark which scenario is "decisive": the one
     that fails if the wrong option is implemented. It is the most valuable test. -->

### E2E-1 — Main flow

1.
2.

✅ **Expected**:

### E2E-2 — <decisive scenario>

---

## 5. Regression

<!-- Required when you touch a shared flow. List each area and what must be confirmed
     as NOT changed. -->

| Area | Check |
|---|---|

---

## 6. Performance

| Metric | Threshold |
|---|---|

---

## 7. Security testing

| Check | Expected |
|---|---|

<!-- Minimum: a call with another tenant's token must return 403; the response must not leak
     card numbers, raw provider error codes or technical details; logs must not hold sensitive data. -->

---

## 8. Commands

```bash
cd <workspace>/services/<repo> && mvn -q clean test
```

```bash
cd <workspace>/services/<repo> && mvn -q clean verify -DskipUTs=true
```

---

## 9. "Testing done" criteria

- [ ] The whole decision table passes
- [ ] The decisive scenario (E2E-?) passes
- [ ] Regression is clean
- [ ] Perf meets the threshold
- [ ] Sonar has no new blocker/critical
- [ ] Self-check / Cross-check subtasks closed
