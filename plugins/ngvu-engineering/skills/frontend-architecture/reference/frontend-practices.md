# Frontend technologies & practices (cite from here)

Cite when recommending. Mark others `[unverified]`. Anchors: **React docs** (react.dev), **Next.js docs**
(nextjs.org/docs), **web.dev / Core Web Vitals** (Google), **MDN**, **TanStack Query docs**, **Tailwind /
Radix / shadcn docs**, **WCAG 2.2 (W3C)**, **OWASP**, **Patterns.dev**, **Testing Library / Playwright /
Vitest docs**, **TypeScript docs**.

## Framework & rendering
- **React** = the UI library; **Next.js** = the full framework (routing, rendering, bundling, data) on top.
  Source: react.dev "Start a New React Project"; nextjs.org.
- **Rendering strategies**: **CSR** (client-only SPA — fast to build, poor SEO/first paint, heavy JS),
  **SSR** (per-request HTML — good SEO/freshness, server cost/TTFB), **SSG** (build-time static — fastest,
  cacheable, stale until rebuild), **ISR** (static + background revalidate — best of SSG with freshness),
  **RSC / streaming** (React Server Components — less client JS, server data access, complexity cost).
  Source: Next.js "Rendering" docs; web.dev "Rendering on the Web" (Google).
- **Next.js App Router (RSC)** vs **Pages Router** vs **Vite + React SPA**: App Router for SEO/SSR/streaming
  + server data; Vite SPA for internal app-behind-login with no SEO need (simpler, lighter). Source:
  nextjs.org App Router docs; vitejs.dev. Tradeoff: capability/SEO ↔ complexity/server-cost.

## Project structure & monorepo
- **Feature-based / colocation** over type-based folders; keep related UI/logic/tests together. Source:
  react.dev "Thinking in React"; Kent C. Dodds "Colocation".
- **Monorepo** (Turborepo / Nx) for multiple apps + shared design-system/utils packages; remote caching,
  task graph. Tradeoff: shared code/consistency ↔ tooling complexity. Avoid for a single small app. Source:
  turbo.build; nx.dev.
- **Design system as a package** (its own build, versioning, Storybook). Source: Storybook docs; bit.dev.

## State management
- **Separate server state from client state** — the key principle. Server state (data from APIs) →
  **TanStack Query (React Query)** / SWR (caching, revalidation, dedup, stale-while-revalidate). Client/UI
  state → **Zustand** (simple, minimal) / **Jotai** (atomic) / **Redux Toolkit** (large apps, devtools,
  middleware) / Context (small, low-frequency). Source: TanStack Query docs ("it's not state, it's a
  cache"); redux.js.org; zustand/jotai docs.
- **URL as state** for shareable/filter state (searchParams). **Forms**: React Hook Form (+ Zod) for
  perf/validation. Source: Next.js searchParams; react-hook-form.com; zod.dev.
- Tradeoff: don't reach for Redux when server-state + a little Zustand/URL state suffices (common
  over-engineering). Source: TanStack/Redux maintainers' guidance.

## Data fetching & API
- **RSC + Server Actions** (Next App Router): fetch on the server, mutate via actions — less client JS,
  secrets stay server-side. Source: Next.js "Data Fetching", "Server Actions".
- **Client fetching**: TanStack Query / SWR over `fetch`/axios for cache+revalidate; Suspense for loading.
- **API style**: REST (ubiquitous), **GraphQL** (client-shaped queries, over/under-fetch fix, heavier),
  **tRPC** (end-to-end typesafe, TS-only full-stack, no codegen). Tradeoff: flexibility/typing ↔ complexity/
  ecosystem. Source: graphql.org; trpc.io.
- **Caching layers**: Next fetch cache + `revalidate`/tags; React Query cache; HTTP/CDN cache. Source:
  Next.js Caching docs.

## Styling & design system
- **Tailwind CSS**: utility-first, no runtime cost, great DX at scale, consistent tokens; con: verbose
  markup, learning curve. **CSS Modules**: scoped, zero-runtime, plain CSS. **vanilla-extract**: typed
  zero-runtime CSS-in-TS. **CSS-in-JS (styled-components/Emotion)**: dynamic theming but **runtime cost +
  RSC-incompatible by default** — declining for SSR/RSC. Source: tailwindcss.com; CSS Modules; vanilla-
  extract.style; "Why we're breaking up with CSS-in-JS" (Emotion maintainer).
- **Component primitives**: **Radix UI** (unstyled, accessible) + **shadcn/ui** (copy-in components on
  Radix+Tailwind) for control; **MUI / Mantine / Chakra** for batteries-included. Tradeoff: control/bundle ↔
  speed-to-build. Source: radix-ui.com; ui.shadcn.com; mui.com.
- **Design tokens** (color/space/type scales) as the single source of truth. Source: W3C Design Tokens CG.

## Performance & Core Web Vitals
- **Core Web Vitals**: **LCP** < 2.5 s, **INP** < 200 ms, **CLS** < 0.1 (75th percentile). Source: web.dev
  Core Web Vitals (Google) — these gate SEO ranking.
- **Levers**: code-splitting / dynamic import, route-level lazy loading, **next/image** (responsive, lazy,
  modern formats), **next/font** (no layout shift), prefetching, minimize client JS (RSC), bundle budgets,
  tree-shaking, avoid hydration of static content, edge caching. Source: web.dev "Fast load times"; Next.js
  "Optimizing".
- **Measure**: Lighthouse / PageSpeed, `web-vitals` lib (field/RUM), bundle analyzer. Source: web.dev.

## Accessibility & i18n
- **WCAG 2.2** (target AA): semantic HTML first, ARIA only when needed, keyboard operability, focus
  management, color contrast, labels. Source: W3C WCAG; MDN Accessibility. **Tools**: axe, eslint-plugin-
  jsx-a11y, Playwright/axe in CI.
- **i18n**: next-intl / react-intl / i18next; locale routing; **RTL** support; ICU message format; avoid
  string concatenation. Source: next-intl docs; formatjs.io.

## Testing (the Testing Trophy)
- **Static** (TypeScript + ESLint) → **Unit/Component** (Vitest/Jest + **React Testing Library** — test
  behavior, not implementation) → **Integration** (MSW to mock the network) → **E2E** (**Playwright** or
  Cypress, few but high-value). Plus **visual regression** (Chromatic/Playwright snapshots) and **a11y**
  tests. Source: Kent C. Dodds "Testing Trophy"; testing-library.com; playwright.dev; mswjs.io.

## Frontend security
- **XSS** is the #1 frontend risk: rely on React's escaping, avoid `dangerouslySetInnerHTML` (sanitize with
  DOMPurify if unavoidable). **CSP** header to contain XSS. Source: OWASP XSS Prevention Cheat Sheet; MDN CSP.
- **Auth token storage**: prefer **httpOnly, Secure, SameSite cookies** over `localStorage` (XSS-exfil
  risk). **CSRF**: SameSite + anti-CSRF tokens for cookie auth. Source: OWASP Cheat Sheets (Session, CSRF).
- **Secure headers** (CSP, HSTS, X-Content-Type-Options, Referrer-Policy, frame-ancestors). **Server
  Actions / RSC**: treat as a server endpoint — authorize + validate input (don't trust the client). **Deps**:
  SCA/`npm audit`, lockfile, no secrets in client bundles (only `NEXT_PUBLIC_*` reach the client). Source:
  OWASP; Next.js security docs.

## Tooling & DX
- **TypeScript strict mode**; **ESLint** (+ jsx-a11y, import) / **Biome** (fast all-in-one); **Prettier**;
  **Storybook** for component dev/docs; **Husky + lint-staged** pre-commit; env via typed schema (Zod).
  Source: typescriptlang.org; biomejs.dev; storybook.js.org. Bundler: **Turbopack** (Next) / **Vite**.

## Deployment & observability
- **Hosting**: **Vercel** (first-class Next.js, edge, ISR, preview deploys — con: cost/lock-in) vs
  **self-host** (Node server / Docker / K8s — control/cost ↔ ops burden) vs static export to a CDN. Source:
  Next.js "Deploying"; vercel.com. **Edge vs Node runtime** tradeoff (cold-start/latency ↔ API compatibility).
- **Observability**: **RUM** with `web-vitals` → analytics; **Sentry** for errors + performance; OTel for
  traces; **feature flags** (LaunchDarkly/Unleash) to decouple deploy from release. Source: web.dev;
  sentry.io; martinfowler.com "Feature Toggles".
- **CI**: typecheck + lint + unit + e2e + **bundle-size budget** as gates; preview deploy per PR.

## Right-sizing guidance
- **Internal app, no SEO** → Vite + React SPA + TanStack Query + Tailwind + Playwright is a complete,
  lightweight stack; Next.js/RSC/monorepo may be over-engineering.
- **Public, SEO-critical, content-heavy** → Next.js App Router with SSG/ISR/RSC earns its complexity.
- Don't add GraphQL/tRPC/monorepo/Redux without a concrete driver. Performance and a11y budgets are never
  optional for a user-facing Big-Tech product.
