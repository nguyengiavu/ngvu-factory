# EPIC {{EPIC}} — {{TITLE}}

> **Epic**: [{{EPIC}}](https://example.atlassian.net/browse/{{EPIC}}) · **Status**: ? · **Team**: ? · **Fix Version / Sprint**: ?
> **Analysis date**: {{DATE}} · **Budget**: DEEP · **Snapshot**: `<repo>@<commit>` (full list in [13](13-METHOD-AND-EVIDENCE.md) §4)

**Verdict:** <!-- 2-3 sentences: what the epic really needs, where it differs from the epic description. The reader has only 2 minutes. -->
**Why it can be trusted:** <!-- primary sources read + the biggest limit (point to 13 §6). -->

---

## 1. Five most important findings

| # | Finding | Evidence |
|---|---|---|
| 1 | | `repo/path/File.java:line` ✔ |

## 2. Recommendation

<!-- One option (point to 07), its score against the next option, the order of work along the critical path (point to 08). -->

## 3. Decisions you need to make

1.

## 4. Child tickets

| Story | Jira | Investigation folder | Jira status |
|---|---|---|---|
| S1 | VUNG-? | [VUNG-?-slug](../VUNG-?-slug/README.md) or — | |

<!-- Child folders sit at the same tasks/ level (created with scripts/new-child.sh). The source table the factory reads is
     08-STORY-BREAKDOWN.md § Factory queue; this table is only an index. -->

## 5. Contents

| File | Content |
|---|---|
| [01-EPIC-AND-CONTEXT.md](01-EPIC-AND-CONTEXT.md) | Jira epic + children, R-list, AC testability, C-n conflicts, release constraints |
| [02-SYSTEM-MAP-AND-RELATIONSHIPS.md](02-SYSTEM-MAP-AND-RELATIONSHIPS.md) | Modules, owners, relationships, impact matrix, trust boundaries |
| [03-FLOW-AND-DATA-FLOW.md](03-FLOW-AND-DATA-FLOW.md) | Processing flows, decision trees, where data fields go and where they get lost |
| [04-DATABASE-AND-TABLES.md](04-DATABASE-AND-TABLES.md) | Related tables/collections, indexes, schema proposal, read-only check queries |
| [05-CODE-ANALYSIS.md](05-CODE-ANALYSIS.md) | Code reading with `file:line`, "Today" table, ngvu pitfalls |
| [06-EDGE-CASES-AND-DRIFT.md](06-EDGE-CASES-AND-DRIFT.md) | Edge cases, drift between points in time |
| [07-OPTIONS-EVALUATION.md](07-OPTIONS-EVALUATION.md) | Design axes, options, scoring, what not to do, trade-offs |
| [08-STORY-BREAKDOWN.md](08-STORY-BREAKDOWN.md) | Stories, dependencies, critical path, Factory queue table |
| [09-TEST-PLAN.md](09-TEST-PLAN.md) | Test matrix, decisive scenarios, AC → test traceability |
| [10-DEPLOY-AND-TEST-DATA.md](10-DEPLOY-AND-TEST-DATA.md) | Branches, pipeline, migrations, DEV data, work needing approval, rollback |
| [11-ROADMAP-AND-DOD.md](11-ROADMAP-AND-DOD.md) | Milestones, roadmap risks, DoD per story and for the whole epic |
| [12-OPEN-QUESTIONS.md](12-OPEN-QUESTIONS.md) | Questions with a default recommendation, ordered by deadline |
| [13-METHOD-AND-EVIDENCE.md](13-METHOD-AND-EVIDENCE.md) | Method, agent assignments, snapshots, limits |
| [evidence/](evidence/README.md) | Original reports per area (E0 Jira inventory, E1 epic verbatim, E2…En code) |
| [diagrams/WORKFLOW.md](diagrams/WORKFLOW.md) | Mermaid diagrams |
| diagrams/presentation.html · presentation.en.html | Presentation in `reportLanguage` · English copy (only when `reportLanguage` is not `en`) — Artifact links: ? · ? |

## 6. Reading notes

Confidence labels `CONFIRMED` · `STRONG_INFERENCE` · `INFERENCE` · `HYPOTHESIS` · `UNKNOWN`; ✔ = line re-read by me.
