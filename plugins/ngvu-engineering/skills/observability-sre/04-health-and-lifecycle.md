Act as an engineer designing health checks and lifecycle.

Generate file: 04-health-and-lifecycle.md

Design probes and lifecycle that K8s and operators can trust (cite §Health & lifecycle):
- **Liveness**: "restart me if THIS process is wedged" — process-level only. Must NOT check downstream
  dependencies (or a dependency blip cascades into mass restarts). Flag any always-200 or dependency-
  checking liveness as an anti-pattern.
- **Readiness**: "send me traffic only if I can serve it" — check the dependencies the request path needs
  (DB, downstream services, broker) with short timeouts; remove from rotation when not ready.
- **Startup probe**: grace for slow starts (JVM warmup) so liveness doesn't kill a slow boot.
- **Graceful shutdown**: on SIGTERM, stop accepting new work, drain in-flight, close resources, then exit
  within the termination grace period.
- **Self-diagnostics**: a richer health/info endpoint for humans (version, dependency status) — separate
  from the probe endpoints.

For choices: options → pros/cons → scored pick, cited. If reviewing, cite file:line; call out always-200
liveness, missing readiness dependency checks, or missing graceful shutdown.

Output: Metadata header; the three probe definitions (what each checks, timeouts, thresholds) with example
config; graceful-shutdown plan; findings (if reviewing). Cross-link cloud-infrastructure step 02.
