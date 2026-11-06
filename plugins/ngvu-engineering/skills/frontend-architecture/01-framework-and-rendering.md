Act as a frontend architect choosing the framework and rendering strategy. THE pivotal decision.

Generate file: 01-framework-and-rendering.md

Decide with explicit tradeoffs (cite `reference/frontend-practices.md` §Framework & rendering):
- **Framework**: Next.js (App Router) vs Vite + React SPA vs Remix/TanStack Start. Scored matrix weighted
  by step-00 (SEO need, scale, interactivity, team skill). Rule of thumb to justify: SEO/public-content →
  Next.js; internal app-behind-login with no SEO → Vite SPA (simpler, lighter); state the why.
- **Rendering strategy per route/section**: CSR / SSR / SSG / ISR / RSC + streaming. Explain each in one
  line (what it optimizes, what it costs), then map the app's main route groups to a strategy. Cite
  web.dev "Rendering on the Web". Example: marketing pages → SSG/ISR; dashboard → CSR/RSC; product pages →
  ISR.
- **RSC vs client components**: where the server/client boundary sits and why (less client JS vs
  complexity); when to opt out (`"use client"`).
- **Runtime**: Node vs Edge per route (tradeoff: latency/cold-start ↔ API compatibility).

For each: options → pros/cons → tradeoff axis → scored pick → WHY, cited. Right-size: flag if Next.js/RSC
is over-engineering for the app (a Vite SPA would do).

Output: Metadata header; framework decision matrix; route→rendering-strategy table; RSC boundary rule;
runtime decision. This sets the foundation for structure, data, and deploy.
