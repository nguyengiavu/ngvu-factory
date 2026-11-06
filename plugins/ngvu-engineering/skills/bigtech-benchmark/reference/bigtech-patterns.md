# Big-Tech practice catalog (cite from here)

Canonical, well-documented practices used by hyperscalers, grouped by pillar. Each entry names the
company, the practice, and a real, checkable source. **When a benchmark report recommends a practice,
cite the matching entry here.** If you need a practice not listed, mark it `[unverified-source]` rather
than inventing a citation.

> Right-sizing reminder: these are the *target patterns*. For an internal microservice, the goal is
> usually the *principle* (e.g. "have SLOs and error budgets"), not the *scale* (e.g. "run global
> Spanner"). Always recommend the level the system actually warrants.

---

## 01 — Scalability & elasticity
- **Google — stateless services + horizontal scaling on Borg/Kubernetes.** The unit of scale is the
  stateless replica; state lives in backing stores. Source: *Site Reliability Engineering* (Beyer et al.,
  O'Reilly 2016), ch. "The Production Environment at Google"; Borg paper (Verma et al., EuroSys 2015).
- **YouTube/Vitess — horizontal sharding of MySQL.** Vitess shards a single logical DB across many
  instances transparently. Source: vitess.io docs; CNCF Vitess case study.
- **Amazon/AWS — cell-based architecture & shuffle sharding** to bound blast radius. Source: AWS
  Well-Architected Reliability Pillar; Builders' Library "Workload isolation using shuffle-sharding".
- **Netflix — autoscaling on demand curves** (predictive + reactive). Source: Netflix Tech Blog,
  "Scryer: predictive auto scaling".
- **Backpressure / load shedding** — reject early under overload rather than collapse. Source: Google SRE
  ch. "Handling Overload" and "Addressing Cascading Failures".

## 02 — Reliability & resilience (SRE)
- **Google — SLIs/SLOs/error budgets** as the contract that governs release velocity vs reliability.
  Source: *Site Reliability Engineering*, chs. "Service Level Objectives" & "Embracing Risk"; *The SRE
  Workbook* (2018), "Implementing SLOs".
- **Netflix — Hystrix / resilience4j circuit breakers, bulkheads, timeouts**; fail fast, isolate. Source:
  Netflix Tech Blog "Making the Netflix API more resilient"; resilience4j docs.
- **Netflix — Chaos Engineering (Chaos Monkey / Simian Army)** to prove resilience in production. Source:
  principlesofchaos.org; Netflix Tech Blog "The Netflix Simian Army".
- **Idempotency keys** for safe retries on write APIs (Stripe is the canonical reference). Source: Stripe
  API docs "Idempotent requests"; AWS Builders' Library "Making retries safe with idempotent APIs".
- **Outbox / transactional messaging** to avoid dual-write loss. Source: microservices.io "Transactional
  Outbox"; Debezium docs.
- **DR with explicit RPO/RTO, multi-AZ/region, regular failover drills.** Source: AWS Well-Architected
  Reliability Pillar; Google SRE "Data Integrity".

## 03 — Performance & latency
- **Multi-tier caching** (client → CDN/edge → app → distributed cache → DB). Source: Facebook *Scaling
  Memcache at Facebook* (Nishtala et al., NSDI 2013); AWS caching whitepaper.
- **CDN / edge delivery** for static + cacheable dynamic content. Source: Netflix Open Connect; Cloudflare
  / Akamai architecture docs.
- **Connection pooling & keep-alive; avoid per-request TCP/TLS handshakes.** Source: AWS Builders' Library
  "Timeouts, retries, and backoff with jitter"; HikariCP docs.
- **Tail-latency engineering (p99/p999), hedged/tied requests.** Source: Dean & Barroso, *The Tail at
  Scale* (CACM 2013).
- **N+1 elimination, batching, pagination by default.** Source: general DB best practice; GraphQL
  DataLoader pattern docs.

## 04 — Security & zero-trust
- **Google — BeyondCorp zero-trust** (trust the request, not the network). Source: BeyondCorp papers
  (Ward & Beyer, ;login: 2014); cloud.google.com/beyondcorp.
- **Secrets management + rotation** (Vault / cloud KMS / Workload Identity); never commit secrets.
  Source: HashiCorp Vault docs; Google Cloud "Workload Identity"; OWASP Secrets Management Cheat Sheet.
- **mTLS service-to-service identity (SPIFFE/SPIRE; service mesh).** Source: spiffe.io; Istio security docs.
- **Supply-chain security: SBOM, signed artifacts, SLSA, dependency/CVE scanning.** Source: slsa.dev;
  SLSA framework; Sigstore/cosign docs.
- **OWASP ASVS / Top 10** as the application-security baseline. Source: OWASP ASVS; OWASP Top 10 (2021).
- **Least privilege, short-lived credentials, audit logging.** Source: Google SRE "Security"; AWS
  Well-Architected Security Pillar.

## 05 — Data architecture
- **Right storage for the job; polyglot persistence.** Source: AWS "Purpose-built databases"; Fowler
  "PolyglotPersistence".
- **Explicit consistency model; tunable consistency.** Source: Amazon *Dynamo* paper (DeCandia et al.,
  SOSP 2007); DynamoDB docs.
- **Event streaming as the integration backbone (log as source of truth).** Source: Kreps "The Log"
  (LinkedIn); Kafka docs; Netflix Keystone pipeline.
- **CQRS / materialized read models for read-heavy access.** Source: microservices.io "CQRS"; Young/Fowler
  on CQRS.
- **Schema evolution & online migrations (expand/contract).** Source: Google "Online, Asynchronous Schema
  Change in F1" (VLDB 2013); GitHub gh-ost.
- **Partitioning, TTL/retention, archival for unbounded growth.** Source: AWS storage best practices.

## 06 — Observability
- **Four golden signals: latency, traffic, errors, saturation.** Source: Google SRE ch. "Monitoring
  Distributed Systems".
- **Three pillars + OpenTelemetry** (metrics, logs, traces; vendor-neutral instrumentation). Source:
  opentelemetry.io; *Observability Engineering* (Majors et al., O'Reilly 2022).
- **Distributed tracing (Dapper lineage).** Source: Google *Dapper* paper (Sigelman et al., 2010); Jaeger
  docs.
- **SLO-based alerting (alert on symptoms / burn rate, not causes).** Source: *The SRE Workbook*,
  "Alerting on SLOs".
- **Structured logging + high-cardinality events.** Source: Honeycomb docs; *Observability Engineering*.

## 07 — Delivery & DevOps
- **CI/CD with trunk-based development & fast pipelines.** Source: DORA *Accelerate* (Forsgren, Humble,
  Kim 2018); Google "Engineering Practices".
- **Progressive delivery: canary, blue-green, automated rollback.** Source: Google SRE "Canarying
  Releases"; Argo Rollouts / Spinnaker docs.
- **Feature flags decouple deploy from release.** Source: martinfowler.com "Feature Toggles"; LaunchDarkly
  docs.
- **DORA metrics (deploy frequency, lead time, change-fail rate, MTTR).** Source: DORA / *Accelerate*.
- **Infrastructure as Code + GitOps.** Source: Terraform docs; Argo CD / GitOps principles (OpenGitOps).

## 08 — Operability & cost
- **Capacity planning from demand forecasts + headroom.** Source: Google SRE "Software Engineering in
  SRE" / capacity planning; AWS Well-Architected Performance Pillar.
- **FinOps: tag, attribute, and optimize cloud cost continuously.** Source: FinOps Foundation framework;
  AWS Cost Optimization Pillar.
- **Runbooks, blameless postmortems, on-call hygiene, toil budget (<50%).** Source: Google SRE chs.
  "Being On-Call", "Postmortem Culture", "Eliminating Toil".
- **Graceful degradation & feature fallbacks under partial failure.** Source: Netflix Tech Blog
  "Fault Tolerance in a High Volume, Distributed System".

---

## How to right-size (worked guidance)
- **QPS unknown / low (internal service):** target Level 3–4 on reliability, security, observability;
  Level 2–3 on scalability (stateless + autoscaling is enough; no sharding/CDN). Skip cell-based arch.
- **Customer-facing or high-fan-in:** raise performance & scalability targets to 4; add edge caching only
  if content is cacheable and latency-sensitive.
- **Financial / compliance data:** security, data integrity, and audit targets go to 4–5 regardless of QPS.
- **Always justify** why the chosen target is the stopping point — cite the criticality from step 00.
