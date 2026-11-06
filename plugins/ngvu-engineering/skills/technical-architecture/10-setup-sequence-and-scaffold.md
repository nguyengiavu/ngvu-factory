Act as a tech lead writing the exact build order. THIS IS THE KEY DELIVERABLE.

Generate file: 10-setup-sequence-and-scaffold.md

Produce a concrete, ordered, do-this-then-that checklist to stand the system up so cross-cutting concerns
(security, observability, CI, contracts) are present from the start, not retrofitted. Follow the
setup-sequence principle in `reference/architecture-patterns.md` and adapt to the decisions in steps 02–09.

For EACH ordered step give: **what to do**, **why it's at this position in the order** (the dependency/
rationale), and the **done-when** check. Recommended order (adapt, don't blindly copy):
1. Repository + branching model + CODEOWNERS + README/CLAUDE.md.
2. CI skeleton (build, unit test, lint, format) + IaC skeleton.
3. App skeleton on the chosen framework; config + **secrets wiring** (manager, not env files).
4. **Observability baseline** (structured logs, golden-signal metrics, tracing, health) — before features.
5. **Security baseline** (authN/Z filter, TLS, dependency/secret scanning in CI).
6. **First vertical slice**: one real endpoint end-to-end through every layer + the datastore + one
   integration — the "walking skeleton" that proves the whole stack.
7. CD pipeline → deploy the slice to staging.
8. Contract tests + integration tests against neighbors.
9. Production deploy behind a feature flag; canary; dashboards/alerts live.
10. Iterate features on the proven skeleton.

Also produce a **scaffold tree** (directory/module layout) and a **"definition of ready to build
features"** checklist (everything that must be green before feature work starts).

Output: Metadata header; the ordered checklist (step | what | why-here | done-when); scaffold tree;
readiness checklist. This is the page a developer follows on day one.
