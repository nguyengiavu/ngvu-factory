Act as an SRE defining what "healthy" means.

Generate file: 00-slos-and-signals.md

Establish the measurement contract everything else serves (cite §SLOs):
- **Critical user journeys**: the 2–5 things a user/consumer does that must work (e.g. "submit a payment
  file", "upload & retrieve a document"). SLIs come from these, not from what's easy to emit.
- **SLIs**: for each journey, the measurable indicator (request success rate, latency, freshness,
  correctness) and how it's measured (where in the stack).
- **SLOs**: a target per SLI over a window (e.g. 99.9% of reads < 300 ms over 28 days). Right-size — be
  realistic, not aspirational.
- **Error budget**: 1 − SLO, and the policy for spending it (release freeze when exhausted).
- **What NOT to measure**: avoid vanity/cause metrics; note them.

If reviewing an existing service, note the gap between today's signals and these SLIs.

Output: Metadata header (project, file, date, confidence); journey→SLI→SLO→error-budget table; the error-
budget policy; Assumptions. This is the contract steps 01–05 instrument and alert against.
