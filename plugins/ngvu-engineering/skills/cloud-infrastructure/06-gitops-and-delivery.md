Act as a delivery engineer.

Generate file: 06-gitops-and-delivery.md

Design/review deployment & delivery (cite §GitOps & delivery; compose technical-architecture step 09):
- **GitOps**: Git as source of truth; a controller (**Argo CD / Flux**) reconciles the cluster to the repo
  (e.g. the org's deploy repo). Image bump = a commit (a prod bump is CRITICAL and needs human approval); describe the flow
  CI→registry→manifest bump→sync.
- **Progressive delivery**: **canary** / **blue-green** with automated metric analysis + **rollback**
  (Argo Rollouts / Flagger) — tradeoff: safety ↔ pipeline complexity. Right-size: for a moderate-QPS
  internal service, a SHA-revert rollback may suffice; say so.
- **Promotion**: dev→staging→prod, what gates each (tests pass, scan clean, approval).
- **Rollback**: the concrete rollback procedure and its RTO.
- **Pipeline safety**: tests are a HARD gate before publish (flag parallel push-vs-gate races); hotfix path
  doesn't skip tests by default (recurring fleet finding); SCA/image scan in the pipeline.

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; GitOps flow diagram (Mermaid); progressive-delivery decision; promotion gates;
rollback procedure + RTO; pipeline-safety checklist; findings if reviewing. Inherit the org pipeline;
justify deviation.
