---
type: llm
weight: 1
---

PASS only if ALL hold for the final answer:
1. Line 1 is exactly `VERDICT: CHANGES`.
2. It flags that `exportAll` has no `@PermissionAllowed` (new endpoint without an explicit permission).
3. It flags that the query ignores `tenantId` (cross-tenant read, tenant isolation broken).
4. It flags that the raw JWT / token is written to the log.

FAIL if line 1 is `VERDICT: PASS`, or if any of 2-4 is missing.
