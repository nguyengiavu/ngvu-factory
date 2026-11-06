Act as a cloud architect.

Generate file: 07-cloud-architecture.md

Design/review the cloud footprint (cite §Cloud architecture, Well-Architected):
- **Managed vs self-run**: prefer purpose-built managed services (managed DB, queue, secrets, object store)
  where they remove undifferentiated toil — scored per service with tradeoff (control ↔ ops burden ↔ cost
  ↔ lock-in).
- **Network**: VPC, private subnets, least-privilege IAM/service accounts, private endpoints; no public
  exposure of internal components.
- **Availability**: **multi-AZ** for HA; **multi-region** only if the SLO/DR target demands it (right-size
  — it's expensive and complex). State the resulting availability vs the SLO.
- **Identity**: workload identity (no long-lived keys); least-privilege roles per workload.
- **Well-Architected pass**: a quick check across reliability, security, performance, cost, operational
  excellence pillars; note the biggest gap.

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; managed-services decision table; network/IAM plan; AZ/region decision vs SLO;
workload-identity plan; Well-Architected gap note. Right-size: don't buy multi-region or premium managed
tiers a workload doesn't need; don't run a thing you can rent.
