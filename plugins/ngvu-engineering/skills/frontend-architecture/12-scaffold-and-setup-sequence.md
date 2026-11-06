Act as a frontend tech lead writing the exact build order. THIS IS THE KEY DELIVERABLE.

Generate file: 12-scaffold-and-setup-sequence.md

Produce a concrete, ordered "create the project in this order" checklist so cross-cutting concerns (types,
lint, testing, a11y, security headers, observability, design tokens) are present from the start, not
retrofitted. Adapt to the decisions in steps 01–11. For EACH step: **what to do** (with the actual command/
config where helpful), **why it's at this position**, and the **done-when** check.

Recommended order (adapt, don't blindly copy):
1. Scaffold the app (`create-next-app --ts` / `npm create vite@latest -- --template react-ts`) per step 01;
   set Node version (.nvmrc), package manager (pnpm), repo + monorepo tooling if step 02 chose it.
2. **TypeScript strict + path aliases**; shared tsconfig.
3. **Lint/format + pre-commit hooks** (ESLint/Biome + Prettier + Husky + lint-staged) — quality gate before
   any feature code.
4. **Styling + design tokens** baseline (Tailwind config / CSS variables) + the component primitive lib
   (Radix/shadcn or chosen lib); a couple of base components.
5. **App shell & routing**: layout, error boundary, not-found, loading; the route/rendering strategy from 01.
6. **Data layer**: API client + TanStack Query/SWR provider (or RSC fetch pattern) + Zod schemas; auth
   wiring; typed env.
7. **Security baseline**: secure headers / CSP, auth-token handling, secrets audit (per step 09).
8. **Observability baseline**: web-vitals RUM + Sentry + error boundary reporting (per step 11).
9. **Testing harness**: Vitest + RTL + MSW + Playwright config + one test of each type (the "walking
   skeleton" of tests).
10. **First vertical slice**: one real feature end-to-end (route → component → data fetch → state → render),
    accessible and tested — proves the whole stack.
11. **CI/CD**: typecheck + lint + test + **bundle-size budget** gates; preview deploy; deploy the slice.
12. **Storybook / docs** (if step 10 chose it); then iterate features on the proven skeleton.

Also produce: the **scaffold directory tree** (feature-based, from step 02) and a **"definition of ready
to build features"** checklist (everything green before feature work).

Output: Metadata header; the ordered checklist (step | what + command | why-here | done-when); scaffold
tree; readiness checklist. This is the page a developer follows on day one to stand up the project.
