Act as an SRE-minded engineer hardening the design.

Generate file: 07-reliability-and-bottlenecks.md

Produce:
- **SPOF analysis**: walk every component; is it redundant? failover plan? Table: component | SPOF? |
  mitigation.
- **Bottleneck analysis**: given step-01 numbers, where does it break first as load grows (the next
  scaling wall)? Rank the top 3–5 bottlenecks by when/why they bind.
- **Failure modes**: dependency down, slow dependency, partition, thundering herd, hot key/shard — and
  the design's response (timeout, retry+backoff+jitter, circuit breaker, bulkhead, fallback). Cite Nygard
  / AWS Builders' Library (§Reliability).
- **Rate limiting**: algorithm (token/leaky bucket, sliding window) + where enforced, cited.
- **Tail latency**: p99/p999 risks and mitigations (hedged requests, timeouts), cite Tail-at-Scale.
- **Availability math**: rough composite availability of the dependency chain vs the step-00 SLO.

For mitigations with options, give pros/cons + a scored pick. 

Output: Metadata header; SPOF table; ranked bottlenecks; failure-mode→response table; rate-limit & tail
plans; availability check vs SLO.
