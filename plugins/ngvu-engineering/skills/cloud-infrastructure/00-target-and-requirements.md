Act as a platform engineer scoping the deployment.

Generate file: 00-target-and-requirements.md

Establish what shapes every platform decision:
- **Workload profile**: stateless or stateful? resource profile (CPU/mem, startup time, JVM?), traffic
  pattern (steady/spiky/batch), concurrency, storage needs.
- **Scale & SLO**: expected replicas, peak load, availability target (drives multi-AZ/region, PDB, HPA).
- **Platform target**: cloud + cluster (e.g. GKE), the org's existing chart/pipeline to inherit.
- **Networking/compliance constraints**: data residency, private-only, ingress rules, regulatory.
- **Secrets source**: where secrets come from (Vault/KMS/CSI).
- **Existing state** (if reviewing): current Dockerfile/manifests/IaC — gather read-only, cite file:line;
  never quote secret values.

Output: Metadata header (project, file, date, confidence); workload profile; scale/SLO; platform target +
what's inherited; constraints; secrets source; Assumptions/Missing Information. This right-sizes the rest
(e.g. low/steady → no VPA/mesh/multi-region).
