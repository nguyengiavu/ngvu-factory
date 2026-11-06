---
type: llm
weight: 1
---

PASS only if line 1 of the final answer is exactly `VERDICT: CHANGES` and a finding says that a
migration already merged to master must not be edited (Flyway checksum / databases that already
applied it) and that the column belongs in a NEW migration file. FAIL otherwise.
