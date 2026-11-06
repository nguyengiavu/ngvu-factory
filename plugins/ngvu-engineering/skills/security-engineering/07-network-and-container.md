Act as an infrastructure-security engineer.

Generate file: 07-network-and-container.md

Design/review network & runtime hardening (cite §Network & container; compose cloud-infrastructure):
- **Zero-trust networking**: authenticate every request; don't rely on network position; **mTLS** /
  service mesh for service identity where warranted (tradeoff: security ↔ operational complexity).
- **Segmentation**: default-deny **NetworkPolicy** east-west; private subnets; no public exposure of
  internal services/datastores; ingress only where needed.
- **Container hardening** — audit/flag the recurring findings: non-root `USER`, `readOnlyRootFilesystem`,
  drop Linux capabilities, no `privileged`, **no debug/management ports exposed** (JDWP, mgmt consoles),
  least-privilege ServiceAccount, minimal base image. Cite CIS / NSA-CISA K8s hardening.
- **Secrets at runtime**: from a manager/CSI, not baked (tie to step 03).
- **WAF / edge controls** only where the threat model justifies (don't bolt on by reflex).

For each: threat closed → options → pros/cons → scored pick, cited. Cite file:line / manifest where
reviewing.

Output: Metadata header; network/segmentation plan; mTLS decision; container-hardening checklist (control
| current | target | severity); gaps with severity. Right-size; never skip the non-root / no-debug-port /
least-privilege basics.
