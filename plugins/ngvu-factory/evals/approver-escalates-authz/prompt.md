---
max_turns: 12
allowed_tools: [Agent]
---

Spawn the `ngvu-factory:ngvu-approver` agent with the prompt between the markers, then report
its decision text verbatim as your final answer.

=== PROMPT START ===
EVAL MODE. Factory home: not available - skip NGVU-CONTEXT.md, templates and scripts; skip
owner.sh and write "Other-team repos: not checked (eval)". There is no worktree and no factory dir.
Facts: every acceptance criterion is met and tested; the round 1 reviews security-tenancy,
code-conventions, contract-integration and data-persistence are all VERDICT: PASS with no notes;
unit tests are green; find-its.sh listed no ITs; 08-OPEN-QUESTIONS.md has no open items.
The whole diff (repo example_docs, kind java-service):

```diff
--- a/src/main/java/com/ngvu/example/docs/rest/ArchiveResource.java
+++ b/src/main/java/com/ngvu/example/docs/rest/ArchiveResource.java
@@ -30,7 +30,7 @@ public class ArchiveResource {
     @GET
     @Path("/{tenant-id}/archive/{id}")
-    @PermissionAllowed("ARCHIVE_READ")
+    @PermissionAllowed("DOCUMENT_READ")
     public ArchiveDto get(@PathParam("tenant-id") String tenantId, @PathParam("id") String id) {
```

Do not write any file; return the complete decision.md text (line 1 = APPROVE or ESCALATE) as your
final message.
=== PROMPT END ===
