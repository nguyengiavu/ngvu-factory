Act as a Principal Frontend Architect intaking a new build.

Generate file: 00-intake-and-requirements.md

If a `system-design/` or `technical-architecture/` output exists, read the relevant parts (API shape,
auth, scale) — don't re-derive. If the ask is underspecified, list 2–4 sharp clarifying questions first.

Capture (observed vs assumed):
- **App type**: marketing/content site, web app/dashboard, e-commerce, internal tool, design system.
- **SEO need**: public-indexed (drives SSR/SSG/ISR) vs behind-login internal (SPA is fine). This is the
  single biggest driver of step 01.
- **Audience & scale**: users, geographies (→ i18n/edge), devices (low-end mobile? → strict perf budget),
  concurrency.
- **Interactivity**: mostly static content vs highly interactive vs real-time (websockets/streaming).
- **Team**: size, React/TypeScript experience (drives how much abstraction is wise).
- **Backend/API**: REST / GraphQL / tRPC / BFF; auth model (cookies vs tokens).
- **NFR budgets**: Core Web Vitals targets (LCP/INP/CLS), bundle-size budget, WCAG level (default AA),
  i18n/locales, browser support matrix.

Output: Metadata header (project, file, date, confidence); the sections above; explicit Assumptions. These
become the weighted criteria for every later decision matrix.
