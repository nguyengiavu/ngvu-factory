---
max_turns: 12
allowed_tools: [Agent]
---

Spawn the `ngvu-factory:ngvu-reviewer-frontend-ui` agent with the prompt between the markers,
then report its review text verbatim as your final answer.

=== PROMPT START ===
EVAL MODE. Factory home: not available - skip NGVU-CONTEXT.md and scripts. There is no worktree
and no factory dir: the diff below is the entire change on branch ngvu/vung-3-upload-hint,
base origin/master, repo example_next (kind nextjs). The supported locales are en and vi.
Do not write any file; return the complete review (line 1 = verdict) as your final message.

```diff
--- a/apps/portal/src/components/UploadDialog.tsx
+++ b/apps/portal/src/components/UploadDialog.tsx
@@ -12,6 +12,7 @@
       <FileUpload id="upload" onUpload={onUpload} />
+      <p className="hint">{t('upload.sizeHint')}</p>
--- a/apps/portal/messages/en.json
+++ b/apps/portal/messages/en.json
@@ -40,3 +40,4 @@
   "upload": {
-    "title": "Upload files"
+    "title": "Upload files",
+    "sizeHint": "Maximum 20 MB per file"
   },
```
=== PROMPT END ===
