# cloud-infrastructure

Engineer the cloud + Kubernetes platform layer for a service — containers, workloads, networking, config/
secrets, IaC, GitOps/delivery, cloud architecture, cost — ending with a platform-readiness scorecard.
See `SKILL.md`.

## Produces
A `cloud-infrastructure/` folder of 10 reports (00–09): target & requirements → containerization →
Kubernetes workload → networking & ingress → config & secrets → IaC → GitOps & delivery → cloud
architecture → cost/FinOps → platform-readiness scorecard. Reports include concrete YAML/HCL snippets.

## The promise
**Show the manifest**: deliverables are real YAML/HCL, not prose. Every choice: options → pros/cons →
tradeoff → scored decision → cited source (`reference/platform-practices.md`: Kubernetes/CNCF docs, cloud
Well-Architected, CIS/NSA hardening). **Security defaults enforced** (non-root, no debug ports, resource
limits, default-deny NetworkPolicy, externalized secrets). Right-sized — flags meshes/multi-region/VPA a
workload doesn't need; marks the **fleet-wide base-image/chart/pipeline wins**.

## Relationship to other skills
- The deploy slice of **technical-architecture** (step 09) in depth. Container/network hardening pairs with
  **security-engineering** (step 07); probes pair with **observability-sre** (step 04). DB HA/replication →
  **dba-engineering**. Live outage → **incident-response**.

## Output convention
`output/<project>/cloud-infrastructure/`.
