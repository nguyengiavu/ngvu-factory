Act as a data architect choosing storage and consistency.

Generate file: 05-storage-and-consistency.md

Decide, driven by the access patterns (step 02) and scale (step 01):
- **Storage engine class**: relational / document / wide-column / KV / search / blob — per data set
  (polyglot is fine). Give a scored matrix of the realistic options for THIS data, cited. If a specific
  engine matters (PG/Mongo/MSSQL), note it and hand off to dba-engineering for depth.
- **Consistency model**: strong / linearizable / causal / eventual — per operation. Map to **CAP/PACELC**:
  state what you give up under partition and the else-case latency↔consistency tradeoff. Cite §building-blocks.
- **Caching**: which layer (client/CDN/app/distributed), pattern (cache-aside / read-through / write-
  through/back), TTL + invalidation, **stampede protection**. Justify with the step-01 hot-set numbers.
- **CDN / edge**: only if content is cacheable and latency-sensitive — else say "not warranted".

For each: options → pros/cons → tradeoff axis → scored pick. Show the consistency tradeoff explicitly
(this is where most designs are won or lost).

Output: Metadata header; per-dataset storage decision; consistency map; caching plan; CDN decision; each
with a matrix. Right-size against the numbers.
