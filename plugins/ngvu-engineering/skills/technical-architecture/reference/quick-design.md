# Quick design (one-page HLD)

The quick mode of technical-architecture: one file, `00-hld.md`, in the `technical-architecture/` output
folder, for a feature or service that needs a design before code but not a full build plan. It runs the
thinking of steps 00, 01, 03 and 11 and skips the rest.

## Steps
1. **Frame**: functional scope and key use cases; NFRs (scale, latency, availability, consistency,
   security/compliance, cost, team, time-to-market); constraints (systems to integrate, mandated tech,
   regulation, deadlines). Ask at most four questions for missing NFRs, then state the rest as assumptions.
2. **Decompose** into bounded contexts with one owner each; one writer per dataset.
3. **Choose the style** per [`../03-architecture-style.md`](../03-architecture-style.md), including its
   ngvu precedence, and name the rejected alternative with the NFR that rejected it.
4. **Components and cross-cutting**: responsibilities, sync vs async calls, data ownership; authn/z,
   observability, config/secrets, resilience (timeouts, retries, circuit breakers, idempotency), caching,
   transactions vs sagas, API versioning.
5. **C4**: Context and Container diagrams in Mermaid, plus a sequence diagram for the critical flow.
6. **Trade-offs, risks, evolution**: failure modes, SPOFs, scaling limits and mitigations; what is deferred
   and what would force a re-architecture. Record each significant standalone decision with the
   `adr` skill.

Done when every NFR maps to at least one decision, Context and Container diagrams are drawn, and each
rejected alternative is named with its reason.

## Review checklist
Raise these as findings when the design shows them: microservices sharing a database; a distributed
monolith (chatty sync calls); a dataset without a clear owner; design for imagined scale; failure modes
left unhandled; observability deferred; tech chosen for novelty; no versioning or compatibility plan.
