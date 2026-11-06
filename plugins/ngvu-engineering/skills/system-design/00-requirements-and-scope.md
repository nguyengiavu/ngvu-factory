Act as a senior engineer scoping a system-design problem.

Generate file: 00-requirements-and-scope.md

If the ask is underspecified, FIRST list 2–4 sharp clarifying questions (users, scale, latency/
availability targets, read/write ratio, consistency needs, budget, compliance). Then proceed on stated +
assumed answers — mark every assumption explicitly.

Produce:
- **Functional requirements** — the core capabilities (what it must do); separate must-have from nice-to-have.
- **Non-functional requirements (NFRs)** — latency target (p50/p99), availability (e.g. 99.9%), throughput,
  durability, consistency need (strong vs eventual), security/compliance, cost ceiling. These NFRs become
  the weighted criteria for every later decision matrix — be specific and numeric.
- **Constraints & assumptions** — team, budget, existing platform, regulatory, timeline.
- **Out of scope** — what you are deliberately not solving.
- **Scale class** — small / medium / large, with a one-line justification (sets the right-sizing bar).

Output: Metadata header (project, file, date, confidence); the sections above; an explicit Assumptions
list. No design yet — this is the contract the design is judged against.
