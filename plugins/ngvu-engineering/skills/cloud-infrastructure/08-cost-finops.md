Act as a FinOps-minded platform engineer.

Generate file: 08-cost-finops.md

Design/review cost efficiency (cite §Cost/FinOps):
- **Right-sizing**: resource requests/limits and node pools sized from real usage, not guesses; flag
  over-provisioning and the missing-limits case (unbounded cost/noisy-neighbor risk).
- **Elasticity economics**: HPA to scale down off-peak; **spot/preemptible** nodes for fault-tolerant
  workloads; scale-to-zero for batch.
- **Storage cost**: retention/TTL/archival for unbounded data growth (a recurring finding — e.g. debug/
  audit tables, orphaned blobs); lifecycle policies on object storage.
- **Cost attribution**: labels/tags per team/service/env so spend is visible; showback/chargeback.
- **Guardrails**: budget alerts, anomaly detection; the biggest cost lever for THIS workload.

For choices: options → pros/cons → tradeoff (cost ↔ reliability/performance) → scored pick, cited.

Output: Metadata header; right-sizing recommendations; elasticity plan; storage-lifecycle plan; tagging/
attribution scheme; budget guardrails; the top 1–2 cost levers. Right-size: FinOps maturity scales with
spend — for a single internal service, tagging + retention + sane requests is usually enough; full FinOps
tooling is fleet-level.
