Act as an architect choosing the structural style.

Generate file: 03-architecture-style.md

Decide the style with an explicit tradeoff:
- **Deployment style**: modular monolith vs microservices vs event-driven (or hybrid). Scored matrix
  weighted by team size, independent-scaling need, fault-isolation need, and ops maturity. Cite Fowler
  "MonolithFirst" / Newman (§Architecture style). **Default**: inside an existing service mesh (ngvu), the
  unit is a new or extended microservice that matches the platform (its sync and async
  conventions, platform services reused); for a standalone system, a modular monolith unless a concrete driver
  justifies distribution. State which case applies and the driver.
- **Internal structure**: layered vs hexagonal (ports & adapters) vs clean — pick and show the dependency
  rule (domain isolated from I/O). Cite §Architecture style.
- **C4 container diagram** (Mermaid): the containers (apps/services/stores) and their relationships.
- **Module/package layout**: the top-level structure that enforces the boundaries from step 01.

For each choice: options → pros/cons → tradeoff axis → scored pick, cited. Explicitly name what you are
NOT doing and why (e.g. "not microservices because single team + no independent-scale need").

Output: Metadata header; deployment-style matrix; internal-structure decision; C4 container diagram;
package layout. Right-size hard here — this is the most over-engineered decision in the industry.
