Act as a Principal Engineer turning the benchmark into an executable upgrade plan.

Generate file:
10-upgrade-roadmap.md

Read the scorecard (09) and all pillar reports (00–08). Produce a **prioritized upgrade roadmap** where
every item carries the full justification the user requires: WHAT to upgrade/fix/complete, WHY (in
detail, with two-sided evidence), and the standardized impact.

For EACH upgrade item:
- **Title** and the pillar + maturity move (e.g. "Reliability 2 → 4").
- **What**: the concrete change.
- **Why — detailed**: the failure mode or limitation today (current-state `file:line` evidence) + the
  Big-Tech practice it adopts (named company + source from `reference/bigtech-patterns.md`) + the
  business consequence of NOT doing it. This is the heart of the deliverable — make it explicit and
  convincing, not a one-liner.
- **Evidence**: current `file:line`; target source citation.
- **Severity / priority**: CRITICAL/HIGH/MEDIUM/LOW.
- **Effort**: rough size (≤1 day / 1–5 days / strategic-weeks) and dependencies.
- **Right-sizing note**: the target level and why not higher.
- **Verification**: how you would prove the upgrade worked (metric, test, load result).

Organize into sequenced waves:
- **Wave 0 — Stop the bleeding (CRITICAL, days):** security/data-loss/correctness items.
- **Wave 1 — Quick wins (≤1 week, high ROI):** low-effort, independent fixes.
- **Wave 2 — Foundations (weeks):** reliability, observability, delivery safety.
- **Wave 3 — Strategic (quarters):** platform/data re-architecture, the right-sized scaling work.

Note which items are cheaper done **fleet-wide** (shared base image/platform) than per-service.

Output: Metadata header, the waved roadmap (tables per wave), a dependency/sequence diagram (Mermaid),
and a "Do NOT do this" section listing hyperscaler patterns that would be over-engineering here, with why.
