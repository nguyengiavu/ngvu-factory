Act as a platform lead delivering the readiness verdict.

Generate file: 09-platform-scorecard.md

Consolidate steps 00–08. Do NOT re-analyze — synthesize.

Produce:
- **Platform-readiness scorecard**: score each area 0–5 (containerization, K8s workload/probes/resources,
  networking/segmentation, config/secrets, IaC, GitOps/delivery, cloud architecture, cost) — current vs
  target (right-sized to scale/criticality); weighted overall; show gaps.
- **Findings register**: each gap ranked CRITICAL→LOW with impact, the fix, effort. (Expect: root
  container, exposed debug ports, missing/always-200 probes, no resource limits, no NetworkPolicy, baked
  secrets, tests-not-gating — the recurring fleet set.)
- **Remediation roadmap in waves**: Wave 0 (CRITICAL security/correctness: non-root + drop debug ports +
  externalize secrets + real probes); Wave 1 (resource limits + HPA + NetworkPolicy + image scanning in
  CI); Wave 2 (GitOps/progressive delivery hardening, cost guardrails, IaC drift control).
- **Fleet-wide vs per-service split**: mark what belongs in the shared **base image / chart / pipeline
  template** (non-root base, probe template, scanning step, securityContext defaults) — the cheapest
  leverage across many services — vs service-specific config.
- **Example manifests** index: link the YAML/HCL produced in steps 01–07.

Output: Metadata header; readiness scorecard; ranked findings; waved roadmap; fleet-vs-service split;
manifest index. This is the page that gets a service production-deploy-ready.
