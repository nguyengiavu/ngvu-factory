Act as an engineer wiring distributed tracing.

Generate file: 02-tracing.md

Design tracing across the service and its dependency chain (cite §Tracing):
- **Standard**: OpenTelemetry (note OpenTracing/OpenCensus are deprecated → migrate). If the service has
  present-but-dead instrumentation (a tracer with no exporter, spans started-never-ended), flag it by
  file:line as a bug, not coverage.
- **Context propagation**: W3C Trace Context (`traceparent`) across every hop — inbound HTTP, outbound
  REST clients, and **across async boundaries** (propagate trace context into Pub/Sub/queue messages).
- **Span design**: spans for the meaningful operations (incoming request, each downstream call, DB op),
  ended and exported; useful attributes (no PII/secrets); error status set on failure.
- **Sampling**: head vs tail sampling — tradeoff completeness ↔ volume/cost; pick with rationale, cited.
- **Exporter/backend**: collector + backend (Jaeger/Tempo/cloud); the agent vs SDK approach.

For choices: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; the tracing plan (standard, propagation incl. async, span design, sampling,
export); for existing services, the present-but-dead findings with file:line; the OpenTracing→OTel
migration note. Flag the OTel agent as a fleet-wide base-image win.
