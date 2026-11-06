# Technical-architecture patterns & sources (cite from here)

Patterns for building a new system correctly, with sources. Cite when recommending. Mark others
`[unverified]`. Key texts: **Fundamentals of Software Architecture** (Richards & Ford, O'Reilly 2020);
**Building Microservices 2e** (Sam Newman, 2021); **Domain-Driven Design** (Evans 2003); **Release It! 2e**
(Nygard 2018); **The 12-Factor App** (Wiggins, Heroku); Google SRE; AWS Well-Architected; CNCF.

## Requirements & NFRs
- **NFR / quality attributes ("-ilities")**: performance, scalability, availability, security,
  maintainability, observability, cost. Drive every decision from these. Source: Richards & Ford ch.4
  ("Architecture Characteristics"); ISO/IEC 25010.
- **Architecturally significant requirements** first; defer the rest. Source: SEI / Richards & Ford.

## Boundaries & decomposition
- **Domain-Driven Design**: bounded contexts, ubiquitous language, aggregates; context mapping
  (anti-corruption layer, conformist, shared kernel). Source: Evans, DDD; Vernon, *Implementing DDD*.
- **Service boundary = business capability / bounded context**, not technical layer. Source: Newman,
  *Building Microservices* ch.2; microservices.io "decompose by business capability".
- **Build vs buy vs reuse**: don't build undifferentiated heavy lifting. Source: AWS Well-Architected;
  Wardley mapping.

## Architecture style (pick by tradeoff)
- **Modular monolith** — one deployable, enforced module boundaries. Pro: simplicity, local txns, easy
  refactor; Con: scales as one unit. Best default for new/small teams. Source: Newman, *Monolith to
  Microservices*; "MonolithFirst" (Fowler).
- **Microservices** — independent deploy/scale per service. Pro: team autonomy, independent scaling; Con:
  distributed-systems tax (network, consistency, ops). Source: Newman; Fowler "Microservice Premium".
- **Event-driven** — async via events. Pro: decoupling, resilience, scalability; Con: harder to reason,
  eventual consistency. Source: Richards & Ford ch.14; *Building Event-Driven Microservices* (Bellemare).
- **Layered / hexagonal (ports & adapters)** — isolate domain from I/O. Source: Cockburn, Hexagonal
  Architecture; Richards & Ford ch.10.

## Integration & contracts
- **Sync (REST/gRPC) vs async (events/queues)**: sync for request/response & strong consistency; async
  for decoupling, spikes, long work. Source: Newman ch.4; DDIA ch.4 (encoding/evolution).
- **API contract + versioning + backward compatibility**; consumer-driven contract tests. Source:
  api-design skill; Pact docs; Newman ch.5.
- **Idempotency keys; outbox pattern for atomic write+publish; anti-corruption layer at boundaries.**
  Source: microservices.io; Stripe idempotency docs.

## Security architecture
- **Zero-trust**; authn at the edge + per-service authz; short-lived tokens. Source: Google BeyondCorp.
- **Threat modeling: STRIDE**; do it at design time. Source: Microsoft SDL / *Threat Modeling* (Shostack).
- **Secrets in a manager (Vault/KMS) with rotation; never in code/images.** Source: OWASP Secrets Mgmt
  Cheat Sheet; Vault docs. **OWASP ASVS / Top 10** baseline.
- **Data protection**: encryption at rest/in transit, PII classification, least privilege. Source: AWS
  Well-Architected Security Pillar.

## Reliability & resilience
- **SLI/SLO/error budgets from day one.** Source: Google SRE / SRE Workbook.
- **Stability patterns**: timeout, retry+backoff+jitter, circuit breaker, bulkhead, fail-fast. Source:
  Nygard, *Release It!*; resilience4j.
- **DR with RPO/RTO; graceful degradation.** Source: AWS Well-Architected Reliability Pillar.

## Observability (build in, don't bolt on)
- **Four golden signals; OpenTelemetry for metrics/logs/traces; structured logs + correlation IDs;
  health endpoints; SLO-based alerting.** Source: Google SRE "Monitoring Distributed Systems";
  opentelemetry.io; *Observability Engineering* (Majors et al.).

## Deployment & cloud
- **Containerize; orchestrate on K8s; immutable images; IaC; GitOps.** Source: CNCF; *Kubernetes Up &
  Running*; Terraform docs; OpenGitOps / Argo CD.
- **Progressive delivery: canary / blue-green + automated rollback; feature flags decouple deploy from
  release.** Source: Google SRE "Canarying"; Fowler "Feature Toggles".
- **12-Factor**: config in env, stateless processes, dev/prod parity, logs as streams. Source:
  12factor.net.
- **Environments: dev → staging → prod with parity; secrets per env.** Source: 12-Factor; SRE.

## Setup-sequence principle
Set up in dependency order so cross-cutting concerns are designed in, not retrofitted:
1. Repo + branching + CODEOWNERS → 2. CI (build/test/lint) + IaC skeleton → 3. App skeleton with config
& secrets wiring → 4. Observability (logs/metrics/traces/health) → 5. AuthN/Z + security baseline →
6. First **vertical slice** (one endpoint end-to-end through all layers + datastore) → 7. CD pipeline +
deploy to staging → 8. Contract tests + integration → 9. Production deploy behind a flag.
Rationale: security and observability retrofits are expensive and incomplete; a vertical slice validates
the whole stack before breadth. Source: 12-Factor; Google SRE; "walking skeleton" (Cockburn).

## Right-sizing
- For a standalone system, prefer a modular monolith until you have a *concrete* reason to distribute
  (team scale, independent scaling, fault isolation). The distributed-systems tax is real. Source: Fowler
  "MonolithFirst", Newman. Inside an existing mesh (ngvu), the unit is one more service on the platform.
- Inherit the org platform; divergence must earn its keep.
