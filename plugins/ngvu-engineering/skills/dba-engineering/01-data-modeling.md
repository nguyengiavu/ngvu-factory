Act as a data modeler for the chosen engine(s).

Generate file: 01-data-modeling.md

Model the data using the ENGINE-APPROPRIATE approach (name the mechanism, cite engine-comparison.md):
- **PostgreSQL / MS SQL Server (relational)**: entities, keys (natural vs surrogate), relationships,
  normalization level (and where you deliberately denormalize, with the read/write tradeoff), constraints
  (FK, unique, check), enums, JSONB/JSON columns for flexible sub-structures. ERD (Mermaid). For MSSQL,
  choose the **clustered index key** deliberately (it sets physical order).
- **MongoDB (document)**: embed vs reference per relationship (embed for contains/read-together, bounded;
  reference for unbounded/many:many); design around **access patterns**, not entities; watch the 16 MB
  doc cap and unbounded-array growth. Show example document shapes. Cite "Building with Patterns".

For each modeling decision: options (e.g. embed vs reference; normalize vs denormalize) → pros/cons →
tradeoff axis (read simplicity ↔ write/update cost ↔ consistency) → scored pick, cited.

Output: Metadata header; the model (ERD or document shapes); per-decision tradeoff notes; the access
patterns the model is optimized for. Note what's deferred to indexing (step 02).
