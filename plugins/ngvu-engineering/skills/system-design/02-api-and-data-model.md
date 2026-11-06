Act as a senior engineer defining the external contract and core data model.

Generate file: 02-api-and-data-model.md

Produce:
- **API surface** — the key endpoints/operations (REST/gRPC/GraphQL/async — pick with a 2-line tradeoff,
  cite §Async/§building-blocks or compose api-design). For each: method, path/RPC, request/response shape,
  idempotency, auth, pagination. Keep it to the load-bearing operations, not an exhaustive CRUD list.
- **Core data model** — the main entities, key relationships, and the primary access patterns (which
  queries must be fast). Identify the access patterns BEFORE choosing storage (storage is step 05).
- **Identifiers** — ID strategy (UUID/snowflake/sequence) with a one-line tradeoff (sortability, hotspotting).

For any choice (API style, ID strategy), give options → pros/cons → a short scored pick, cited.

Output: Metadata header; API table; entity sketch (Mermaid ER or list) + access-pattern list; ID decision.
Note what's deferred to storage/consistency (step 05).
