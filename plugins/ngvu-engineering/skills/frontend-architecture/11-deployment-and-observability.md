Act as a frontend delivery & observability engineer.

Generate file: 11-deployment-and-observability.md

Decide (cite §Deployment & observability; compose cloud-infrastructure for self-host depth):
- **Hosting**: **Vercel** (first-class Next.js: edge, ISR, image opt, preview deploys — con: cost/lock-in)
  vs **self-host** (Node server in Docker/K8s — control/cost ↔ ops burden) vs **static export to CDN**
  (cheapest, only for fully static). Scored matrix weighted by step-00 + org constraints; state WHY and the
  lock-in tradeoff. (In ngvu/GKE context, self-host on the cluster is the likely default — note it.)
- **Runtime & caching**: edge vs node per route; CDN in front; ISR/`revalidate` strategy; cache headers;
  image/font optimization in the deploy target.
- **CI/CD**: typecheck + lint + unit + e2e + **bundle-size budget** as gates; **preview deploy per PR**;
  promotion dev→staging→prod; rollback.
- **Observability**: **RUM** via `web-vitals` → analytics (field CWV); **Sentry** for errors + perf +
  source maps; OTel/traces if integrating with backend tracing; structured client logging (no PII).
- **Feature flags**: LaunchDarkly/Unleash/edge-config to decouple deploy from release + safe rollout.
- **SEO/meta** if public: sitemap, robots, structured data, OpenGraph, canonical.

For each choice: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; hosting decision matrix; runtime/caching plan; CI/CD pipeline (with bundle gate +
preview deploys); observability stack (RUM/Sentry/flags); SEO/meta checklist if public. Right-size.
