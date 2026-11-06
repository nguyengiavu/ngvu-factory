Act as a frontend performance engineer.

Generate file: 06-performance-web-vitals.md

Set budgets first, then the levers (cite §Performance & Core Web Vitals):
- **Budgets**: **LCP < 2.5 s, INP < 200 ms, CLS < 0.1** (75th percentile), + a JS bundle-size budget (state
  a KB target for initial route). Explain these gate SEO ranking and UX.
- **Loading levers**: code-splitting / dynamic import, route-level lazy, RSC to cut client JS, tree-shaking,
  avoid large client libs (audit heavy deps), import cost awareness.
- **Assets**: **next/image** (responsive, lazy, modern formats, prevents CLS) or equivalent; **next/font**
  (self-host, no layout shift); SVG sprites; compress.
- **Network**: prefetching (Next Link), HTTP caching/CDN, edge for static, `Cache-Control`, resource hints
  (preconnect/preload).
- **Runtime**: minimize re-renders (keys, memo where measured, virtualization for long lists), avoid
  hydration of static content, INP — keep the main thread free.
- **Measure**: Lighthouse/PageSpeed (lab) + `web-vitals` RUM (field), bundle analyzer, CI bundle budget gate.

For each lever: what it fixes, the expected gain, the tradeoff (e.g. prefetch ↔ bandwidth). Prioritize by
impact.

Output: Metadata header; the budget table; ranked levers (lever | fixes | gain | tradeoff); the
measurement plan + CI budget gate. Right-size: don't micro-optimize a low-traffic internal tool, but never
ship CWV-failing public pages.
