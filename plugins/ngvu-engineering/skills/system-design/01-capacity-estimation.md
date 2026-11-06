Act as a senior engineer doing back-of-the-envelope capacity estimation.

Generate file: 01-capacity-estimation.md

Using the numbers/assumptions from step 00 and the constants in `reference/building-blocks.md`
(§Estimation), compute and SHOW THE WORKING for:
- **Traffic**: DAU → requests/day → average QPS → peak QPS (peak ≈ 2–10x avg; state the factor). Split
  read vs write QPS.
- **Storage**: bytes/record x records/day → /year, with growth; total at 1y/3y.
- **Bandwidth**: ingress/egress per second from payload sizes.
- **Memory / cache**: working-set size for caching the hot 20% (80/20).
- **Connections / fan-out** if relevant.

For each result: state the inputs, the arithmetic, and the rounded answer. Mark every input observed
(given) or inferred (assumed). Then a one-paragraph **"what these numbers imply for the design"** — e.g.
"peak 12k write QPS exceeds a single Postgres node → partitioning likely needed" or "fits one node →
do NOT shard".

Output: Metadata header; the estimates with working; the implications paragraph; Assumptions. Prefer a
table. These numbers right-size every later step — cite them downstream.
