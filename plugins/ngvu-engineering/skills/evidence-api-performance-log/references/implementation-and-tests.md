# Implementation, tests and documentation (Phases 19, 20, 22, 23)

Part of [`evidence-api-performance-log`](../SKILL.md); used after the Phase 18 plan.

---

# Phase 19 — Implementation Requirements

Implementation must be:

```text
centralized
reusable
configurable
testable
low-overhead
production-ready
GCP-friendly
security-aware
```

Do not:

- modify business behavior
- change public API contracts
- instrument unrelated target services
- log secrets
- blindly log bodies
- duplicate instrumentation
- introduce unrelated refactoring
- add a new logging framework without need

---

# Phase 20 — Tests

Create or update tests.

Minimum scenarios:

```text
1. successful GET
2. successful POST
3. query parameters
4. JSON request body
5. null body
6. 4xx response
7. 5xx response
8. timeout
9. connection failure
10. generic client exception
11. sensitive-field redaction
12. oversized body truncation
13. trace ID propagation
14. correlation ID propagation
15. durationMs generated
16. statusCode captured
17. one evidence log per attempt
18. unrelated targets are not instrumented
```

Use the project's existing test stack.

---

# Phase 22 — Documentation

Create:

```text
docs/
└── evidence-logs/
    └── {source}-to-{target}/
        ├── README.md
        ├── 01-current-state.md
        ├── 02-evidence-map.md
        ├── 03-design.md
        ├── 04-implementation.md
        ├── 05-security.md
        ├── 06-tests.md
        └── 07-gcp-queries.md
```

If the project already has a documentation convention, follow it instead.

---

# Phase 23 — Required Diagrams

Generate a Mermaid sequence diagram based on actual evidence.

Replace participants and flow with actual repository evidence.

---
