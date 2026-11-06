# Cloud & Kubernetes platform practices (cite from here)

Cite when recommending. Mark others `[unverified]`. Anchors: **Kubernetes docs** (kubernetes.io),
**CNCF** projects, **AWS/GCP/Azure Well-Architected Frameworks**, **CIS Benchmarks**, **NSA/CISA
Kubernetes Hardening Guide**, **OpenGitOps principles**, **The Twelve-Factor App**.

## Containerization
- **Multi-stage builds** (build deps stay out of the runtime image); **minimal/distroless base**;
  **non-root `USER`**; pinned/digest base image; small layers; no secrets in layers. Source: Docker best
  practices; Google distroless; CIS Docker Benchmark.
- **Image scanning** (Trivy/Grype) in CI; SBOM. Source: CNCF supply-chain; slsa.dev.

## Kubernetes workload
- **Deployment** (stateless) vs **StatefulSet** (stable identity/storage) vs **Job/CronJob** (batch) vs
  **DaemonSet** (per-node). Pick by state needs. Source: Kubernetes Workloads docs.
- **Probes**: liveness (restart), readiness (traffic gating, check deps), startup (slow start). Source:
  Kubernetes probe docs. (See observability-sre for the anti-patterns.)
- **Resources**: set **requests** (scheduling) and **limits** (cap); right-size from real usage; CPU limit
  throttles, memory limit OOM-kills. Source: Kubernetes "Resource Management"; Google SRE capacity.
- **HPA** (horizontal, on CPU/custom/external metrics) vs **VPA** (vertical) — tradeoff. **PodDisruption
  Budget** to protect availability during drains. Source: Kubernetes Autoscaling, PDB docs.
- **securityContext**: `runAsNonRoot`, `readOnlyRootFilesystem`, drop capabilities, `allowPrivilege
  Escalation:false`, seccomp; least-privilege **ServiceAccount**. Source: NSA/CISA K8s Hardening; Pod
  Security Standards (restricted).

## Networking & ingress
- **Service** (ClusterIP/NodePort/LoadBalancer) → **Ingress / Gateway API** for L7 routing + TLS
  termination. Source: Kubernetes Service/Ingress, Gateway API docs.
- **NetworkPolicy** for default-deny east-west segmentation. **Service mesh** (Istio/Linkerd) for mTLS +
  traffic mgmt — powerful but heavy; tradeoff: capability ↔ operational complexity. Source: Kubernetes
  NetworkPolicy; Istio docs.
- TLS everywhere; cert automation (cert-manager). Source: cert-manager docs.

## Config & secrets
- **ConfigMap** for non-secret config; **Secret** for sensitive (note: base64, not encrypted by default —
  enable encryption at rest / use external store). **External secrets** via Vault Agent/CSI or External
  Secrets Operator; never bake secrets into images or commit them. Source: Kubernetes Secrets docs;
  Vault/CSI docs. **12-Factor config**: config in the environment. Source: 12factor.net.

## Infrastructure as Code
- **Terraform/Pulumi**: modular, versioned, remote **state** with locking; plan/review/apply; drift
  detection; separate state per environment. Source: Terraform docs; Well-Architected (OE pillar).

## GitOps & delivery
- **GitOps**: Git is the source of truth; a controller (**Argo CD / Flux**) reconciles cluster to repo.
  Source: OpenGitOps principles; Argo CD/Flux docs.
- **Progressive delivery**: **canary** / **blue-green** with automated analysis + **rollback** (Argo
  Rollouts / Flagger). Tradeoff: safety ↔ pipeline complexity. Source: Argo Rollouts; Google SRE
  "Canarying Releases".

## Cloud architecture
- **Purpose-built managed services** over self-run where it removes undifferentiated toil; **VPC** with
  private subnets, least-privilege IAM, **multi-AZ** for HA (multi-region only if the SLO/DR demands it).
  Source: AWS/GCP/Azure Well-Architected (Reliability + Security pillars).

## Cost / FinOps
- **Right-size** requests/limits and node pools from real usage; autoscale; spot/preemptible for tolerant
  workloads; **tag/label** for cost attribution; alert on anomalies. Source: FinOps Foundation; cloud Cost
  Optimization pillars.

## Right-sizing
- Don't add a service mesh, multi-region, StatefulSet, or VPA a workload doesn't need — each is real
  operational cost. But never skip the cheap correctness/security defaults: probes that check deps,
  resource requests/limits, non-root + dropped caps, no exposed debug ports, externalized secrets.
- **Inherit the org platform** (base image, chart, pipeline); a divergence must earn its keep.
