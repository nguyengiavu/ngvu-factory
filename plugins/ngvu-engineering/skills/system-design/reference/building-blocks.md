# System-design building blocks (cite from here)

Canonical scalable-system building blocks with sources. When a step recommends one, cite the entry.
Mark anything not here `[unverified]`. Primary text: **DDIA = *Designing Data-Intensive Applications*,
Martin Kleppmann, O'Reilly 2017.** Others cited inline.

## Estimation
- **Back-of-envelope numbers**: ~10^5 reads/s from a cache node, ~10^3–10^4 writes/s to a DB node,
  ~1 ms intra-AZ RTT, ~150 ms cross-continent RTT, SSD ~500 MB/s, 1 day ≈ 86,400 s. Source: Dean's
  "Numbers Everyone Should Know" (Jeff Dean, Google); *System Design Primer* (donnemartin, GitHub).
- **Estimate order**: DAU → QPS (peak ≈ 2–10x average) → storage/day → bandwidth → memory for cache
  (80/20 rule). Source: *System Design Primer*; Alex Xu, *System Design Interview* vol. 1–2.

## Load distribution
- **Load balancing** (L4/L7, round-robin / least-conn / consistent-hashing). Source: DDIA ch.6; NGINX/
  Envoy docs. **Consistent hashing** for cache/shard placement: Karger et al. 1997.
- **Stateless app tier + externalized session/state** → horizontal scale. Source: Google SRE "Production
  Environment"; *12-Factor App* (factor VI, processes).
- **Reverse proxy / API gateway** for TLS, routing, auth, rate limit. Source: NGINX/Envoy/Kong docs.

## Partitioning & replication
- **Sharding / partitioning** (range, hash, directory); hot-spot avoidance. Source: DDIA ch.6.
- **Replication** (single-leader, multi-leader, leaderless); replication lag & read-your-writes. Source:
  DDIA ch.5. **Quorum (R+W>N)**: Amazon *Dynamo* paper, SOSP 2007.
- **CAP theorem** (pick 2 of C/A/P under partition); **PACELC** (else: latency vs consistency). Source:
  Brewer 2000 / Gilbert & Lynch 2002; Abadi, PACELC 2012.

## Storage & consistency
- **SQL vs NoSQL fit**: relational for rich queries/joins/ACID; document for hierarchical/flexible;
  wide-column for write-heavy/huge; KV for cache/session. Source: DDIA ch.2–3; AWS purpose-built DBs.
- **Consistency models**: strong, linearizable, sequential, causal, eventual. Source: DDIA ch.9; Jepsen
  consistency map (jepsen.io/consistency).
- **Caching**: cache-aside (lazy), read-through, write-through, write-back; TTL + invalidation; cache
  stampede protection (locking / request coalescing). Source: DDIA ch.1; AWS caching whitepaper; Facebook
  *Scaling Memcache* (NSDI 2013).
- **CDN / edge** for static + cacheable content. Source: Cloudflare/Akamai docs; Netflix Open Connect.

## Async & messaging
- **Message queue vs log/stream** (RabbitMQ/SQS vs Kafka/Pub/Sub); at-least-once + idempotent consumers;
  exactly-once is mostly a myth without dedup. Source: DDIA ch.11; Kafka docs; "The Log" (Kreps, LinkedIn).
- **Event-driven / CQRS / event sourcing**; **outbox** for atomic write+publish. Source: microservices.io;
  Young/Fowler CQRS.
- **Backpressure / load shedding**; bounded queues. Source: Google SRE "Handling Overload".

## Reliability
- **SPOF removal, redundancy, failover, health checks**. Source: AWS Well-Architected Reliability Pillar.
- **Rate limiting** (token bucket, leaky bucket, sliding window). Source: Stripe/Cloudflare engineering.
- **Idempotency keys** for safe retries. Source: Stripe API docs; AWS Builders' Library.
- **Tail latency** (p99/p999), hedged requests. Source: Dean & Barroso, *The Tail at Scale*, CACM 2013.
- **Timeouts, retries with exponential backoff + jitter, circuit breakers, bulkheads**. Source: AWS
  Builders' Library; resilience4j docs; Nygard, *Release It!*.

## Security & multi-tenancy
- **Zero-trust** (authenticate every request; don't trust network position). Source: Google BeyondCorp.
- **Tenant isolation models**: silo (DB per tenant) / pool (shared, row-scoped) / bridge. Source: AWS
  SaaS Lens / multi-tenant SaaS storage whitepaper.
- **Secrets management + rotation**; **OWASP Top 10 / ASVS** baseline. Source: Vault docs; OWASP.

## Right-sizing guidance
- Single well-tuned RDBMS node handles a *lot* (often 10k+ TPS, TBs) — reach for sharding/NoSQL only with
  evidence. Caching and read replicas usually come before sharding.
- A queue is not always needed; add async only when a step is slow, spiky, or must survive consumer
  downtime. Premature event-sourcing/CQRS is a classic over-engineering trap (microservices.io caveats).
