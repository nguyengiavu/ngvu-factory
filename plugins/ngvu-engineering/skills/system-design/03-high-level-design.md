Act as a senior engineer drawing the high-level design.

Generate file: 03-high-level-design.md

Produce:
- **Component diagram** (Mermaid or ASCII): clients → edge (LB/gateway/CDN) → services → datastores /
  caches / queues / external deps. Label each box's responsibility.
- **Primary data flows**: trace the 1–3 most important requests end-to-end (e.g. write path, read path),
  as a sequence diagram or numbered steps — what happens at each hop.
- **Component responsibilities table**: component | responsibility | stateful? | scales how.
- **Key choices made here**: for each non-obvious structural choice (e.g. gateway vs direct, separate
  read service, sync vs async at a given hop), give options → pros/cons → scored pick, cited from
  `reference/building-blocks.md`.

Keep it right-sized to the step-01 numbers — don't add components a small system doesn't need; if you
include one "for future scale", say so and mark it deferred.

Output: Metadata header; the diagram(s); flows; responsibilities table; the decision notes. This is the
backbone the scaling/storage/async steps refine.
