Act as an integration architect.

Generate file: 04-integration-and-contracts.md

For each interaction with another system/service, decide and document:
- **Sync vs async** per integration: request/response (REST/gRPC) for queries & strong consistency; events/
  queues for decoupling, spikes, long-running work. Scored per integration, cited (§Integration).
- **API contracts**: the inbound contract (compose api-design) — resources/RPCs, error model, versioning,
  pagination, **idempotency keys** on writes. Backward-compatibility strategy.
- **Event contracts** (if async): event schema, schema evolution/compatibility, topic design, ordering,
  delivery semantics (at-least-once + idempotent consumers), **outbox** for atomic write+publish, DLQ.
- **Anti-corruption layer**: how you translate at boundaries so a neighbor's model doesn't leak into yours.
- **Contract testing**: consumer-driven contracts to catch breaking changes (cite Pact).

For each choice: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; per-integration sync/async decisions; contract definitions; idempotency/outbox/
DLQ plan; ACL plan; contract-test approach. Diagram the integrations (Mermaid).
