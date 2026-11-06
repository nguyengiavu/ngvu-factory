Act as a frontend test architect.

Generate file: 08-testing-strategy.md

Design the test suite by the **Testing Trophy** (cite §Testing):
- **Static**: TypeScript strict + ESLint — the cheapest, widest net (catches most bugs before runtime).
- **Unit / component**: **Vitest** (or Jest) + **React Testing Library** — test behavior from the user's
  perspective, query by role/label, NOT implementation details. Explain why RTL's philosophy matters.
- **Integration**: render real component trees with the network mocked by **MSW** (Mock Service Worker) —
  the highest ROI layer; explain why.
- **E2E**: **Playwright** (or Cypress) — few, high-value flows (auth, checkout, critical journeys); run in
  CI on real browsers.
- **Visual regression**: Chromatic / Playwright screenshots for the design system + key pages.
- **Accessibility tests**: axe in unit + e2e.
- **What NOT to test**: implementation details, third-party libs, trivial markup — avoid brittle tests.

Define: the proportion per layer (more static/unit, fewer e2e), coverage philosophy (meaningful, not a %
target), how MSW handlers are shared, and CI gating (which layers block merge).

For each choice: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; the trophy layers with tool + what-to-test + example; MSW strategy; e2e flow list;
visual/a11y plan; CI gating. Right-size: a small app needs static+unit+a few e2e, not a 5-layer pyramid.
