Act as a Kubernetes networking engineer.

Generate file: 03-networking-and-ingress.md

Design/review networking (cite §Networking & ingress; show YAML):
- **Service**: ClusterIP (internal default) / LoadBalancer / headless — pick by exposure need.
- **Ingress / Gateway API**: L7 routing, host/path rules, TLS termination, cert automation (cert-manager);
  internal-only vs external.
- **NetworkPolicy**: default-deny east-west; allow only the required ingress/egress (to its DB, the
  services it calls, DNS). A recurring gap — most clusters are flat by default. Show the policy.
- **Service mesh** (Istio/Linkerd): only if mTLS + advanced traffic mgmt is warranted — tradeoff:
  capability ↔ operational complexity; default to "no mesh" for a single service unless the fleet uses one.
- **TLS everywhere**, including internal hops where the threat model requires (tie to security-engineering).
- **Egress control**: no unrestricted outbound; block metadata IP (SSRF defense).

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; Service + Ingress/Gateway YAML; NetworkPolicy (default-deny + allows); mesh
decision; TLS/egress plan; findings if reviewing. Right-size — don't add a mesh a single service doesn't need.
