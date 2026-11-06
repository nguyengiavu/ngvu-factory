---
type: llm
weight: 1
---

PASS only if line 1 of the final answer is exactly `VERDICT: CHANGES` and a finding states that the
new translation key `upload.sizeHint` is missing from `messages/vi.json` (Vietnamese). FAIL if the
verdict is PASS or the missing Vietnamese entry is not identified.
