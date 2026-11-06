Act as the architect closing the loop (compose the adr skill).

Generate file: 11-decision-log-and-roadmap.md

Produce:
- **Architecture Decision Records**: capture each significant decision from steps 02–09 as a short ADR
  (context → options considered → decision → consequences/tradeoffs). Either inline them or write them to
  an `adr/` folder and index here. Cite the adr skill format. This preserves the "why" for future
  maintainers — the user's stated goal.
- **Consolidated tradeoff scorecard**: one table of the big decisions | chosen option | the NFR it
  optimizes | what it sacrifices | confidence. The at-a-glance "why this architecture" view.
- **Risk register**: top risks (technical + delivery), likelihood x impact, mitigation, owner.
- **Build roadmap**: phase the work — Phase 0 (scaffold/walking skeleton from step 10), Phase 1 (core
  features), Phase 2 (hardening/scale) — with rough effort and the exit criteria of each phase.
- **Open questions** that need answers before or during the build.

Output: Metadata header; ADR index/inline ADRs; tradeoff scorecard; risk register; phased roadmap; open
questions. This is the durable record that explains and sequences the whole architecture.
