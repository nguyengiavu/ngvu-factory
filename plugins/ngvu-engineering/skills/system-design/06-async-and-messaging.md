Act as an engineer deciding what becomes asynchronous.

Generate file: 06-async-and-messaging.md

First decide IF async is warranted (don't add a broker by reflex): justify by a slow/spiky/decoupled/
must-survive-downtime step. If sync is fine, say so and stop early.

If async is warranted, address:
- **Queue vs log/stream**: RabbitMQ/SQS-style queue vs Kafka/Pub-Sub-style log — tradeoff (ordering,
  replay, fan-out, retention), scored pick, cited (§Async, DDIA ch.11).
- **Delivery semantics**: at-least-once + **idempotent consumers** (note exactly-once needs dedup); the
  **outbox pattern** for atomic DB-write + publish.
- **Ordering & partitioning** of the topic; consumer scaling.
- **Failure handling**: retries with backoff, **dead-letter queue**, poison-message handling.
- **Backpressure / load shedding**: bounded queues, what happens when consumers fall behind.

For each: options → pros/cons → tradeoff → scored pick, cited.

Output: Metadata header; the "is async warranted?" verdict; per-topic decisions; failure/backpressure
plan. If not warranted, a short justified note is the whole deliverable.
