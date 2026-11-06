Act as a frontend architect designing state management.

Generate file: 03-state-management.md

Apply the key principle FIRST (cite §State management): **separate server state from client state** — most
"state management" pain is from treating cached server data as client state.
- **Server state** (data from APIs): use **TanStack Query (React Query)** or SWR (caching, dedup,
  revalidation, stale-while-revalidate) — or RSC/Server Actions if Next App Router fetches server-side.
  Explain why this is NOT global client state.
- **Client/UI state**: choose among Context (small/low-frequency), **Zustand** (simple global), **Jotai**
  (atomic/derived), **Redux Toolkit** (large app, time-travel/devtools/middleware). Scored matrix weighted
  by app complexity + team familiarity; state WHY and explicitly warn if Redux is over-engineering here.
- **URL/route state**: filters, tabs, pagination → searchParams (shareable, back-button-correct).
- **Form state**: React Hook Form + Zod (perf, validation) vs controlled — tradeoff.
- **Derived state & memoization**: avoid duplicating state; compute; when `useMemo`/selectors matter.

For each: options → pros/cons → tradeoff → scored pick → WHY, cited. Map the app's actual state to the
right home (a table: state → category → tool → why).

Output: Metadata header; the server-vs-client principle; client-state-lib decision matrix; URL/form-state
plan; the "state inventory → home" table. Right-size: prefer server-state + URL state + minimal client
state.
