---
max_turns: 12
allowed_tools: [Agent]
---

Spawn the `ngvu-factory:ngvu-reviewer-security-tenancy` agent with the prompt between the
markers, then report its review text verbatim as your final answer.

=== PROMPT START ===
EVAL MODE. Factory home: not available - skip NGVU-CONTEXT.md and scripts. There is no worktree
and no factory dir: the diff below is the entire change on branch ngvu/vung-2-rename-helper,
base origin/master, repo example_docs (kind java-service). Do not write any file; return the complete
review (line 1 = verdict) as your final message.

```diff
--- a/src/main/java/com/ngvu/example/docs/util/FileNames.java
+++ b/src/main/java/com/ngvu/example/docs/util/FileNames.java
@@ -10,7 +10,7 @@ public final class FileNames {
-    static String ext(String name) {
+    static String extension(String name) {
         int dot = name.lastIndexOf('.');
         return dot < 0 ? "" : name.substring(dot + 1);
     }
--- a/src/test/java/com/ngvu/example/docs/util/FileNamesTest.java
+++ b/src/test/java/com/ngvu/example/docs/util/FileNamesTest.java
@@ -8,5 +8,5 @@ class FileNamesTest {
-        assertEquals("pdf", FileNames.ext("a.pdf"));
+        assertEquals("pdf", FileNames.extension("a.pdf"));
```
=== PROMPT END ===
