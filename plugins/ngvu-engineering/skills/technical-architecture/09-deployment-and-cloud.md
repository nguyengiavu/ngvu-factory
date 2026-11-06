Act as a Platform/DevOps engineer designing build & run.

Generate file: 09-deployment-and-cloud.md

Produce:
- **Packaging**: containerization (image strategy, base image, non-root, multi-stage), immutability.
- **Orchestration & topology**: K8s/serverless/VM — scored pick; replicas, resource requests/limits,
  autoscaling (HPA), pod/security context. Cite CNCF (§Deployment).
- **Cloud architecture**: the cloud services used (compute, managed DB, queue, secrets, object store),
  network (VPC, ingress, service mesh?), multi-AZ. Right-size; don't add managed services you won't use.
- **IaC & GitOps**: infra in code (Terraform), declarative deploy (Argo/GitOps), drift control.
- **Environments**: dev → staging → prod with parity; config per env via env vars (12-Factor); secrets
  per env from the manager.
- **CI/CD**: pipeline stages (build → test → scan → publish → deploy), test as a hard gate, SCA/image
  scanning, **progressive delivery** (canary/blue-green + automated rollback), feature flags. Cite DORA /
  Google SRE (§Deployment).

For each choice: options → pros/cons → tradeoff → scored pick, cited. Inherit the org's deploy platform
by default; justify deviation.

Output: Metadata header; packaging; orchestration/topology decision; cloud-service list; IaC/GitOps plan;
environment matrix; CI/CD pipeline diagram (Mermaid). Right-size to scale & criticality.
