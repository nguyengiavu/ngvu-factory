---
name: ngvu-project-stack
description: Example tech-stack reference for a multi-service Java platform (WildFly/MicroProfile and Quarkus services, PostgreSQL + JPA by default with MongoDB for document workloads, a Next.js frontend, GCP/GKE, Vault, trunk-based branching with PR flow, error-handling and tenancy conventions). It is a template: replace the examples with your own stack. Load it when another ngvu skill says "see the ngvu-project-stack skill", or before giving stack-specific advice for a repo in the workspace.
user-invocable: false
---

# Project Stack - example platform (replace with yours)

Tech-stack context for all skills in this catalog. **Everything below is an example stack.** The service names
(`example_core`, `example_docstore`, ...) are placeholders, not real repositories. Keep the structure, edit the facts
to match your own platform, and re-check them against your code: this file is guidance, not proof.

Source of truth in practice: `<workspace>\CLAUDE.md` (`<workspace>` = factory config `workspace`,
default `D:\workspace`) and each service's own `CLAUDE.md`, which override this file.
When a skill's "Stack notes" reference "ngvu", they mean what is below.

> Always read the workspace `CLAUDE.md` and the target service's own `CLAUDE.md`/`README` before acting.
> A per-service `CLAUDE.md` takes precedence over this file.

## Shape of the system
- **Many repos, not one** - `<workspace>\services` holds independently-versioned microservice repos (each cloned
  from `github.com/nguyengiavu/<service>`). No aggregator build, no shared root `pom.xml`, no shared git history.
  `cd` into the service and treat it as the repo.
- Services communicate over **REST + GCP Pub/Sub**, **not** shared Java packages. Cross-service Java refactors
  are not a normal operation.

## Two runtime stacks (check `pom.xml` first)
| | **WildFly + MicroProfile** (most services) | **Quarkus** (e.g. `example_auth`, `example_storage`) |
|---|---|---|
| Java | 17 | 21 |
| Packaging | `war` | jar / GraalVM **native** image |
| Web layer | **JAX-RS** resources | JAX-RS (RESTEasy Reactive) |
| REST client | **MP REST Client** (`@RegisterRestClient`) | MP REST Client |
| Config | **MP Config** | MP Config / `application.properties` |
| Auth | **MP JWT** (`MP_JWT_VERIFY_PUBLIC_KEY_LOCATION`) | MP JWT |
| Authorization | `@PermissionAllowed` on JAX-RS methods | `@PermissionAllowed` |
| Dev loop | build, deploy to the WildFly base image | `mvn quarkus:dev` (Dev UI at `/q/dev-ui`) |
| Parent | - | `com.ngvu:example-module-parent` |

There is **no Spring** here. Do not reach for Spring Boot/Spring Data idioms: use JAX-RS + MicroProfile (CDI
`@Inject`, `@ApplicationScoped`, MP REST Client, MP Config, MP Fault Tolerance). Group IDs vary
(`com.ngvu.example.*`, `com.ngvu.examplecomp.*`, `com.ngvu.sec.*`): do not normalise them.

## Build & test (run from inside the service dir)
```bash
mvn clean package                               # full build + tests
mvn clean package -DskipUTs=true -DskipITs=true # build only (both flags exist on every service)
mvn test                                        # unit tests
mvn test -Dtest=ClassName                       # single test class
mvn verify                                      # integration tests (often need running deps: Mongo, Vault...)
# Quarkus:
mvn compile quarkus:dev                         # live-reload
mvn clean package -Dnative                      # native image
```
Local dev: `docker-compose up --build` from a service dir. Env-var convention
`APP_<NAME>_HOST_PORT` / `.../mp-rest/url`: the literal `/mp-rest/url` suffix is intentional (MP REST
Client config), do not "fix" it. Compose files contain dev secrets: never commit modified ones.

## Persistence - PostgreSQL + JPA by default, MongoDB for document workloads
Check the service first: `src/main/resources/META-INF/persistence.xml` and `pom.xml`.
- **PostgreSQL via JPA/Hibernate is the norm** (e.g. `example_core`, `example_payment`; datasource
  `java:jboss/datasources/<service>`).
- **Schema migrations**: most services run versioned SQL at startup through a shared `MigrationRunner`
  (an `@Startup` bean calls `runMigration()`; scripts in `src/main/resources/db/<schema>/V<version>__<name>.sql`).
  A few services use Flyway instead. Check which one before writing a migration.
- **MongoDB** only where documents fit: `example_docstore` (a JSON document store other services consume over
  REST) and a few services with their own collections. Use document-model thinking only there.
- Multi-tenant data is keyed by **tenant ID** (a `/{tenant-id}` path segment); per-tenant secrets
  (DB creds, encryption keys) come from **Vault** via the service's `SecretsService`.

## Recurring infrastructure
- **Auth**: every service validates JWTs issued by `example_auth` via MP JWT. Authorization is `@PermissionAllowed`.
- **Caching**: `example_cache` (distributed) often paired with an in-memory tier (a `TwoTierCache`).
- **Async / messaging**: **GCP Pub/Sub** (topic/subscription IDs per env; credentials in each service's `queue/` dir).
- **Audit**: domain events flow through `example_audit`.
- **Service dependency map**: `<service>/catalog-info.yaml` (Backstage) - its `consumesApis` / `dependsOn`
  lists are authoritative for who-talks-to-whom.

## Error & exception handling (platform standard)
Apply this wherever code is written, reviewed, or tested (`feature-build`, `api-design`, the debugging skill
(`slots.yaml` `bugs.diagnose`), `refactor`, `test-strategy`, `system-analysis`, `incident-response`):
- **One error model at the edge.** Map exceptions to a single consistent JSON body + correct HTTP status
  via a **JAX-RS `ExceptionMapper<T>`** (Quarkus: `ExceptionMapper` / `@ServerExceptionMapper`). No raw
  stack trace or container HTML reaches the client. Status mapping: validation -> 400/422, auth -> 401/403,
  not-found -> 404, conflict/optimistic-lock -> 409, rate limit -> 429, unexpected -> 500.
- **Catch narrowly, never swallow.** No empty `catch`; handle meaningfully or let it propagate to the
  mapper. One layer owns logging (do not log-and-rethrow at every level). Preserve the cause
  (`throw new DomainException(e)`), do not `catch (Exception)` blindly.
- **Do not leak.** Never put secrets/Vault material, internal IDs, stack traces, or another tenant's data in
  messages or logs. Keep client-facing messages tenant-safe and generic; put detail in server logs only.
- **Remote calls fail**: wrap every MP REST Client / external call with **MP Fault Tolerance**:
  `@Timeout`, `@Retry` (idempotent ops only), `@CircuitBreaker`, `@Fallback` where degradation is OK.
  Translate downstream errors into your own domain errors instead of leaking theirs.
- **Async (Pub/Sub) errors**: consumers must be **idempotent** (messages redeliver); ack only on success,
  nack/retry on transient failure, route poison messages to a **dead-letter** topic after N attempts,
  never silently drop. Log with the message/correlation id.
- **Persistence**: distinguish not-found from error; treat optimistic-concurrency conflicts (JPA
  `@Version`, Mongo `version`) as 409/retry. JPA: keep one transaction per use case and watch for
  lost updates without a lock. Mongo (`example_docstore`): **no cross-document transactions by default**,
  design for partial failure / compensation.
- **Fail fast on missing config/secrets** at startup (e.g. an absent Vault secret), loudly, not as a later NPE.
- **Observe**: log each unexpected exception **once**, at the boundary, with correlation id + context; emit
  a metric; send domain-significant failures to `example_audit` where appropriate.

## Deploy & release
- **CI/CD**: GCP **Cloud Build** (`cloudbuild.yaml`): Maven build, docker build/push to
  `<region>-docker.pkg.dev/<project>/<repo>/<service>:$COMMIT_SHA`, then bump the `example_deploy` manifest
  via `bump_image_tag.sh`. Runtime is **Kubernetes**. WildFly services build `FROM` an
  `example-wildfly-base` image and patch `standalone.xml` from `deployment/wildfly/config/`.
- **Branching (trunk-based on `master`)**: `master` is the trunk; most repos have no `develop`.
  Ticket branches are `<team>/vung-<n>-<slug>` (epic child `<team>/vung-<epic>/vung-<n>-<slug>`;
  `branchPrefix` in machine.json) and go by PR into `master` or the epic branch; the human merges.
  The flow and naming live in `<workspace>\CLAUDE.md` and `rules/safe-command-policy.md` (branch -> PR flow).
- **Build & release**: Cloud Build on a `master` commit builds the image and bumps it in `example_deploy`
  (`cloudbuild.yaml`, `_DEPLOY_REPO_BRANCH_NAME`; which environment that reaches is defined in
  `example_deploy`). Versions are cut with `maven-release-plugin`. AI never triggers a release or a manifest
  bump on its own.
- **Exceptions with GitFlow**: a few repos keep `develop` and `release/*` plus `release_candidate.sh` /
  `release.sh` (never run unprompted, they push branches/tags). Check `git branch -r` before assuming.

## Debugging across services
General method: the `superpowers:systematic-debugging` skill when that plugin is installed, else
your own debugging skill; with neither, reproduce, isolate and prove the root cause before any fix.
Specifics for this stack:
- Reproduce locally with `docker-compose up --build` in the service dir (a "needs review" command per
  `safe-command-policy.md`); run the failing test with `mvn test -Dtest=ClassName`, or `quarkus:dev` for
  Quarkus services.
- In the REST + Pub/Sub mesh the cause often sits **across a boundary**: a failing MP REST Client call, a
  JWT rejection from `example_auth`, a missing Vault secret, a store query (`example_docstore`, or the
  service's own database: check `persistence.xml` / `pom.xml`), a stale `example_cache` entry, or a Pub/Sub
  message. Pick the service from `catalog-info.yaml` and traces.
- Logs live in Kubernetes pods: `ngvu-flow-logs` (a multi-service request flow) or
  `ngvu-pod-health`, time-bounded per `cost-token-policy.md`.
- "Works locally but not in prod": suspect the latest Cloud Build / `example_deploy` image bump, per-env
  config (`/mp-rest/url`), or a per-tenant difference.

## Quick implications for skills
- **Error/exception handling** -> follow the platform standard above: one `ExceptionMapper`-based error
  model, narrow catches, no leakage, MP Fault Tolerance on remote calls, idempotent Pub/Sub consumers.
- **DBA skills** -> default to PostgreSQL + JPA/Hibernate and `MigrationRunner` SQL migrations; use the
  MongoDB document model only for the document services; partition/index by tenant either way.
- **Java code skills** -> JAX-RS + MicroProfile (or Quarkus), CDI injection, MP REST Client, MP Config, MP
  Fault Tolerance for resilience; Maven; JUnit. **Not Spring.**
- **Architecture / API skills** -> REST + Pub/Sub mesh, MP JWT auth, Vault, multi-tenancy by path,
  `catalog-info.yaml` as the dependency source of truth, Kubernetes deploy.
- **Ops / incident skills** -> Kubernetes + Cloud Build; rollback = redeploy the previous image tag by
  reverting the `example_deploy` bump (CRITICAL, human approval first); Pub/Sub and Vault as common
  failure points.
