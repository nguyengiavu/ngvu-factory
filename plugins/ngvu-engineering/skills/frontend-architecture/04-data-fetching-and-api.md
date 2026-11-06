Act as a frontend architect designing data fetching & API integration.

Generate file: 04-data-fetching-and-api.md

Decide (cite §Data fetching & API):
- **API style** to consume: REST vs **GraphQL** (client-shaped queries, fixes over/under-fetch, heavier
  tooling) vs **tRPC** (end-to-end TS typesafety, no codegen, TS-backend only) vs a **BFF**. Scored matrix
  weighted by backend reality + typing need + team. State WHY and the tradeoff.
- **Where fetching happens**: server (RSC / Server Actions / loaders) vs client (TanStack Query/SWR). Map
  the app's data to each: initial/SEO/secret-bearing → server; user-interaction/polling/real-time →
  client. Explain the why.
- **Caching & revalidation**: Next fetch cache + `revalidate`/tags, React Query cache config (staleTime/
  gcTime), HTTP/CDN cache — and how they layer. Cache invalidation strategy on mutation.
- **Mutations**: Server Actions vs client mutations + optimistic updates + cache invalidation.
- **Loading & error UX**: Suspense + error boundaries, skeletons, retry, offline; type-safe responses
  (Zod parse at the boundary).
- **Real-time** (if needed): websockets/SSE; how it coexists with the cache.

For each: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; API-style decision matrix; server-vs-client fetch map; caching/revalidation plan;
mutation+optimistic-update pattern; loading/error UX standard. Right-size (don't add GraphQL/tRPC without a
driver).
