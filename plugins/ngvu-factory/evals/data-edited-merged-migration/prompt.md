---
max_turns: 12
allowed_tools: [Agent]
---

Spawn the `ngvu-factory:ngvu-reviewer-data-persistence` agent with the prompt between the
markers, then report its review text verbatim as your final answer.

=== PROMPT START ===
EVAL MODE. Factory home: not available - skip NGVU-CONTEXT.md and scripts. There is no worktree
and no factory dir: the diff below is the entire change on branch ngvu/vung-4-order-note,
base origin/master, repo example_core (kind java-service). The file V2025.03.11.1__ADD_ORDER_TABLE.sql
has been on master since March 2025. Do not write any file; return the complete review
(line 1 = verdict) as your final message.

```diff
--- a/src/main/resources/db/public/V2025.03.11.1__ADD_ORDER_TABLE.sql
+++ b/src/main/resources/db/public/V2025.03.11.1__ADD_ORDER_TABLE.sql
@@ -5,6 +5,7 @@ CREATE TABLE store_order (
     tenant_id   VARCHAR(36)  NOT NULL,
     created_at  TIMESTAMP    NOT NULL,
+    note        VARCHAR(500),
     PRIMARY KEY (id)
 );
```
=== PROMPT END ===
