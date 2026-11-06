Act as an IaC engineer.

Generate file: 05-infrastructure-as-code.md

Design/review the infrastructure-as-code (cite §IaC; show HCL/structure):
- **Tool**: Terraform vs Pulumi vs cloud-native (CDK/Deployment Manager) — scored pick with tradeoff;
  default to the org standard.
- **Module structure**: reusable modules; DRY across environments; clear inputs/outputs; versioned modules.
- **State**: remote backend with locking (GCS/S3 + lock); **state per environment**; never local state for
  shared infra; secrets not in state where avoidable.
- **Environments**: dev/staging/prod as separate state + variable sets with parity; promotion flow.
- **Drift**: `plan` in CI, review before `apply`; detect/alert on drift; no manual console changes
  ("ClickOps") that escape code.
- **What's IaC vs GitOps**: cluster/cloud resources via IaC; in-cluster app manifests via GitOps (step 06)
  — draw the boundary.

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; tool decision; module/repo layout; state & environment strategy; the
plan→review→apply flow; the IaC-vs-GitOps boundary; findings if reviewing. Right-size — don't over-modularize
a small footprint.
