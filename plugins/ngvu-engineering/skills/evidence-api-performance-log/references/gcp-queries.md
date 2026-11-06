# GCP queries (Phase 21)

Part of [`evidence-api-performance-log`](../SKILL.md). Time-bound every query (`~/.claude/rules/cost-token-policy.md`): add
`timestamp>="<start>" timestamp<="<end>"` to each query below.

---

# Phase 21 — GCP Queries

Generate queries matching the actual log format.

Logs instrumented before the rename carry the legacy marker; to search them too, match
`textPayload:"###EVIDENCE" OR textPayload:"###NGVU"`.

## All evidence logs

Plaintext:

```text
textPayload:"###EVIDENCE"
```

Structured:

```text
jsonPayload.marker="###EVIDENCE"
```

## Source to target

```text
jsonPayload.marker="###EVIDENCE"
jsonPayload.sourceService="{source}"
jsonPayload.targetService="{target}"
```

## Slow calls

```text
jsonPayload.marker="###EVIDENCE"
jsonPayload.durationMs > 1000
```

## HTTP 500

```text
jsonPayload.marker="###EVIDENCE"
jsonPayload.statusCode=500
```

## Failures

```text
jsonPayload.marker="###EVIDENCE"
jsonPayload.outcome="FAILURE"
```

## Timeouts

```text
jsonPayload.marker="###EVIDENCE"
jsonPayload.outcome="TIMEOUT"
```

Adapt queries to the actual GCP payload fields found in the project.

---
