---
type: llm
weight: 1
---

This case is a false-positive control. PASS only if line 1 of the final answer is exactly
`VERDICT: PASS` and the Findings section raises no blocking security or tenancy problem (it may say
"not applicable" or "None"). FAIL if the verdict is `VERDICT: CHANGES` or a blocking finding is
invented for this pure rename.
