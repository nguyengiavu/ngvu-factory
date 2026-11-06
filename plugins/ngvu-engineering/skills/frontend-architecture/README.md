# frontend-architecture

Design and scaffold a new large-scale, Big-Tech-grade React / Next.js frontend system end to end.
See `SKILL.md` for the pipeline.

## Produces
A `frontend-architecture/` folder of 13 reports (00–12): intake & requirements → framework & rendering
(CSR/SSR/SSG/ISR/RSC) → project structure & monorepo → state management → data fetching & API → styling &
design system → performance & Core Web Vitals → accessibility & i18n → testing strategy → frontend
security → tooling & DX → deployment & observability → **the ordered scaffold/setup sequence**.

## The promise
Every choice: **options → pros/cons → tradeoff axis → scored decision matrix → WHY → cited source**
(`reference/frontend-practices.md`: React/Next.js/web.dev/library official docs, WCAG, OWASP). Performance
and accessibility are stated as **numeric budgets** (LCP/INP/CLS, bundle KB, WCAG AA). Right-sizing is
enforced — it names what would be over-engineering (RSC/monorepo/GraphQL/Redux where a Vite SPA + server
state suffices). Step 12 is a real ordered checklist to stand up the project on day one.

## Relationship to other skills
- The frontend counterpart to **technical-architecture** (backend/service build). Backend/scale blueprint →
  **system-design**; data tier → **dba-engineering**; deep security → **security-engineering**; self-host
  deploy on K8s → **cloud-infrastructure**; one library pick → **tech-evaluation**; record a decision → **adr**.

## Output convention
`output/<project>/frontend-architecture/`.
