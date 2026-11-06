Act as a Kubernetes engineer defining the workload.

Generate file: 02-kubernetes-workload.md

Design/review the workload manifest (cite §Kubernetes workload; show the YAML):
- **Workload kind**: Deployment (stateless) vs StatefulSet (stable identity/storage) vs Job/CronJob vs
  DaemonSet — scored pick from step-00 profile. Default Deployment unless state demands otherwise.
- **Probes**: liveness (process-only), readiness (checks deps), startup (slow-start grace) — with timeouts/
  thresholds. Cross-link observability-sre step 04; flag always-200 probes.
- **Resources**: `requests` + `limits` for CPU & memory, right-sized with rationale (note: CPU limit
  throttles, memory limit OOM-kills; for JVM set heap vs container limit deliberately).
- **Autoscaling**: HPA (metric + min/max + thresholds) vs VPA — tradeoff; only if scale warrants.
- **Availability**: replicas, **PodDisruptionBudget**, anti-affinity / topology spread for AZ resilience.
- **securityContext**: `runAsNonRoot`, drop capabilities, `allowPrivilegeEscalation:false`, seccomp;
  least-privilege ServiceAccount. Cite NSA/CISA hardening; flag gaps.

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; the example Deployment/StatefulSet YAML (probes, resources, securityContext,
HPA, PDB); the hardening checklist (current vs target if reviewing); right-sizing notes on resources/HPA.
