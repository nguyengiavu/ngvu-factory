Act as a Principal Engineer intaking a new build.

Generate file: 00-intake-and-requirements.md

If a `system-design/` output exists, read it and summarize the relevant blueprint — do NOT re-derive it;
this skill turns it into a buildable architecture. If not, capture the essentials directly.

Produce:
- **What we're building** — one paragraph; the module/service/system and its job.
- **Functional scope** — capabilities in/out of scope.
- **Non-functional requirements (the "-ilities")** — performance, scalability, availability, security,
  maintainability, observability, cost — each with a concrete target where known. These NFRs weight every
  later decision matrix (cite §Requirements in `reference/architecture-patterns.md`).
- **Constraints** — existing platform to inherit, team size/skills, compliance, timeline, budget.
- **Scale class & criticality** — sets right-sizing + how much rigor (financial/PII raises it).
- **Integration footprint** — what existing systems it must talk to.

Output: Metadata header (project, file, date, confidence); the sections; explicit Assumptions. This is
the contract the architecture is built against.
