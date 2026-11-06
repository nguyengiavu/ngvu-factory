Act as the author assembling a Big-Tech-style design doc / RFC.

Generate file: 10-design-doc.md

Consolidate steps 00–09 into one readable design doc a reviewer could approve. Do NOT re-derive — quote
and link the prior sections. Structure:
1. **Summary / TL;DR** — what we're building, the scale, the headline design in 3–5 sentences.
2. **Goals & non-goals** (from 00).
3. **Requirements & scale** (from 00–01, key numbers).
4. **Proposed design** — the high-level diagram + data flows (from 03), refined by 04–06.
5. **Detailed design** — storage/consistency (05), scaling (04), async (06), API/data (02).
6. **Reliability, security, multi-tenancy** (07–08).
7. **Alternatives & tradeoffs** (from 09) — the honest comparison.
8. **Risks & open questions**.
9. **Rollout plan** — phases, how we'd validate at each (load test, canary).
10. **Appendix** — capacity math, references.

Keep it tight and skimmable: tables, diagrams, decisions with one-line rationale. A senior reviewer
should be able to read the TL;DR + tradeoffs and understand the whole design.

Output: Metadata header; the doc sections above. This is the primary deliverable; everything else is its
working.
