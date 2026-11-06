Act as a Principal Architect setting the bar for a Big-Tech benchmark.

Generate file:
00-baseline-and-scope.md

GOAL: establish the system's real scale, criticality, and reliability needs. This sets the **target
maturity level** for every later pillar — without it, scoring is arbitrary and you will over-engineer.

Read first (in priority order):
1. Any existing `system-analysis/` reports for this target (00, 03, 05, 07, 13, 16, 17, 20, 24) — use them
   as the current-state baseline; do not re-derive.
2. If absent, scan: build files, API specs, Dockerfile/cloudbuild/K8s manifests, `catalog-info.yaml`,
   service `CLAUDE.md`, any k6/load-test config.

Establish and record (mark each observed vs inferred; never fabricate a number):
- **Domain & criticality**: what the service does; is it customer-facing or internal; financial /
  compliance / PII data? (drives security & data-integrity targets)
- **Scale signals**: QPS/throughput if known (from k6, configs, logs); data volume; tenant/user count;
  fan-in/fan-out (how many services call it / it calls). If unknown, say so and classify conservatively.
- **Current reliability posture**: any SLO/SLA, uptime expectation, on-call, incident history if visible.
- **Platform & constraints**: runtime, deploy target, team size signals, fleet context (shared base image).

Then DECIDE the **target maturity level (0–5) per pillar** for THIS system, with a one-line justification
each, using the rubric in SKILL.md and the right-sizing guidance in `reference/bigtech-patterns.md`.
Present as a table: Pillar | Target level | Why this level (not higher).

Output schema:
- Metadata header (project, file, pillar=baseline, date, confidence)
- System profile (domain, criticality, scale signals, platform)
- Target-level table (the contract the rest of the benchmark scores against)
- Missing Information (what you could not verify and how it would change targets)
