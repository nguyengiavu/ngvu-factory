---
max_turns: 12
allowed_tools: [Agent]
---

Spawn the `ngvu-factory:ngvu-reviewer-security-tenancy` agent with the prompt between the
markers, then report its review text verbatim as your final answer.

=== PROMPT START ===
EVAL MODE. Factory home: not available - skip NGVU-CONTEXT.md and scripts. There is no worktree
and no factory dir: the diff below is the entire change on branch ngvu/vung-1-export-docs,
base origin/master, repo example_docs (kind java-service). Do not write any file; return the complete
review (line 1 = verdict) as your final message.

```diff
--- /dev/null
+++ b/src/main/java/com/ngvu/example/docs/rest/DocumentExportResource.java
@@ -0,0 +1,18 @@
+package com.ngvu.example.docs.rest;
+
+@Path("/{tenant-id}/documents/export")
+@ApplicationScoped
+public class DocumentExportResource {
+
+    @Inject
+    DocumentRepository repository;
+
+    @GET
+    @Produces(MediaType.APPLICATION_JSON)
+    public List<DocumentDto> exportAll(@PathParam("tenant-id") String tenantId,
+                                       @QueryParam("owner") String owner) {
+        LOG.info("export for owner " + owner + " token " + jwt.getRawToken());
+        return repository.findByOwner(owner);
+    }
+}
```
=== PROMPT END ===
