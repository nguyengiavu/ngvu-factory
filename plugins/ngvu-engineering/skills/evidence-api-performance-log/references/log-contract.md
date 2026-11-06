# Log contract (Phases 6–17)

Part of [`evidence-api-performance-log`](../SKILL.md). Every mode applies all of it.

---

# Phase 6 — Required Evidence Log Marker

Use this default marker:

```text
###EVIDENCE
```

Default relation:

```text
[{source} -> {target}]
```

Required plain-text pattern:

```text
###EVIDENCE [{source} -> {target}] | Method: {method} | Endpoint: {routeTemplate} | Params: {redactedParams} | Body: {bodySummary} | Start: {startTime} | End: {endTime} | Duration: {durationMs}ms | Status: {statusCode}
```

The exact prefix must remain:

```text
###EVIDENCE
```

unless the user explicitly requests another marker.

---

# Phase 7 — Structured Logging Preferred

Prefer GCP-compatible structured logging when supported by the existing stack.

Recommended schema:

```json
{
  "message": "Outbound API performance",
  "marker": "###EVIDENCE",
  "eventType": "OUTBOUND_API_PERFORMANCE",
  "sourceService": "{source}",
  "targetService": "{target}",
  "method": "POST",
  "endpoint": "/documents/search",
  "routeTemplate": "/documents/search",
  "queryParams": {
    "page": "1"
  },
  "body": {
    "documentId": "abc123"
  },
  "startTime": "2026-07-10T07:10:15.123Z",
  "endTime": "2026-07-10T07:10:15.368Z",
  "durationMs": 245,
  "statusCode": 200,
  "outcome": "SUCCESS",
  "traceId": "...",
  "spanId": "...",
  "correlationId": "..."
}
```

Keep numeric values numeric.

---

# Phase 8 — Timing Requirements

Use separate concepts for timestamps and elapsed duration.

## Wall-clock timestamps

Use UTC ISO-8601.

For Java prefer:

```java
Instant.now()
```

for:

```text
startTime
endTime
```

## Monotonic duration

For Java prefer:

```java
System.nanoTime()
```

Example:

```java
long startNanos = System.nanoTime();

try {
    // execute outbound request
} finally {
    long elapsedNanos = System.nanoTime() - startNanos;
    long durationMs =
        TimeUnit.NANOSECONDS.toMillis(elapsedNanos);
}
```

Do not calculate performance duration only by subtracting wall-clock timestamps
when a monotonic clock is available.

Explain why.

---

# Phase 9 — Capture Required Fields

Capture where technically available:

```text
marker
eventType
sourceService
targetService
method
endpoint
routeTemplate
queryParams
body
startTime
endTime
durationMs
statusCode
outcome
errorType
errorMessage
traceId
spanId
correlationId
requestId
attempt
maxAttempts
```

Do not fabricate unavailable values.

---

# Phase 10 — Success and Failure

Handle:

```text
2xx
3xx
4xx
5xx
timeout
connection refused
DNS failure
SSL/TLS failure
client exception
cancellation
unknown transport failure
```

Recommended outcomes:

```text
SUCCESS
FAILURE
TIMEOUT
CANCELLED
```

Always emit a duration once an attempt has started.

---

# Phase 11 — Sensitive Data Protection

Never blindly log:

```text
Authorization
Bearer token
JWT
OAuth token
API key
password
secret
cookie
session ID
private key
credential
personal data
medical data
PII
business-sensitive fields
```

Inspect the actual domain and identify sensitive fields.

Default redaction keys include:

```text
password
passwd
secret
token
access_token
refresh_token
authorization
api_key
apikey
cookie
set-cookie
client_secret
private_key
```

Do not log authorization headers.

---

# Phase 12 — Body and Parameter Safety

Do not use unsafe raw string concatenation.

Requirements:

- log `routeTemplate` (e.g. `/{tenant-id}/documents`), never the resolved path: a real tenant id
  in a log line is `TENANT_REDACTED` (`~/.claude/rules/data-protection-policy.md`)
- `bodySummary` is off by default (`evidence.logging.include-body=false` → size and content type only);
  when enabled, log only allowlisted non-PII fields (ids, counts, flags) — document content, names and
  addresses never; `redactedParams` applies the redaction keys of Phase 11
- safely serialize JSON
- escape control characters
- remove line breaks from plaintext logs when needed
- emit one logical event per API attempt
- handle null values
- handle malformed content
- handle non-JSON content
- avoid consuming request streams
- avoid consuming response streams

---

# Phase 13 — Body Size Protection

Implement configurable truncation.

Recommended configuration concept:

```text
evidence.logging.max-body-length=4096
```

Avoid:

- logging huge payloads
- base64 payloads
- binary data
- file uploads
- unbounded JSON documents

Explain GCP cost and performance implications.

---

# Phase 14 — Trace Correlation

Inspect existing trace context.

Reuse:

```text
traceId
spanId
correlationId
requestId
```

Do not create a parallel tracing system when one already exists.

Search for:

```text
OpenTelemetry
OTel
MDC
traceparent
X-Request-ID
X-Correlation-ID
Cloud Trace
Micrometer
Telemetry
```

---

# Phase 15 — Retry Awareness

Inspect retries.

Determine whether logs represent:

- each physical attempt
- the complete logical operation
- both

Do not hide retry-induced latency.

---

# Phase 16 — Reactive and Streaming Safety

If the project is reactive or non-blocking:

- preserve event-loop behavior
- do not block
- do not consume streams
- do not duplicate large buffers
- do not break streaming responses
- do not alter backpressure behavior

Inspect technologies such as:

```text
Mutiny
Uni
Multi
Reactor
Mono
Flux
Vert.x
RxJS
async/await
```

Implementation must match the current execution model.

---

# Phase 17 — Logging Severity

Propose severity based on current project conventions.

Suggested default:

```text
successful normal call -> INFO
slow call              -> WARNING
HTTP 5xx               -> ERROR
timeout                -> ERROR
transport failure      -> ERROR
```

Configurable thresholds:

```text
evidence.logging.slow-threshold-ms=1000
evidence.logging.very-slow-threshold-ms=5000
```

---
