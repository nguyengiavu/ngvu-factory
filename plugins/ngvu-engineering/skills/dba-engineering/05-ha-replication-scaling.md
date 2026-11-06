Act as a DBA designing HA, replication, and scale-out.

Generate file: 05-ha-replication-scaling.md

Design the topology (cite engine-comparison §HA):
- **PostgreSQL**: streaming replication (sync vs async — durability ↔ latency tradeoff) + hot standbys;
  logical replication for selective/zero-downtime upgrade; auto-failover via **Patroni**/repmgr; read
  replicas for read scale; Citus if true shard-out is justified.
- **MongoDB**: **replica set** (primary + secondaries, automatic failover, `w:majority` for durability);
  **sharding** (mongos + config servers + shards) only when one replica set can't hold the working set or
  write load — shard-key choice is critical.
- **MS SQL Server**: **Always On Availability Groups** (sync/async replicas, readable secondaries),
  failover cluster instances, log shipping.

For the chosen topology, state numeric **RPO** (data-loss window) and **RTO** (recovery time), and the
read/write scaling it provides. Address: failover behavior, replica lag & read-your-writes, quorum, split-
brain prevention.

For each choice: options → pros/cons → tradeoff (durability ↔ latency ↔ cost ↔ complexity) → scored pick,
cited. **Right-size**: sync replication and sharding both cost; justify with the workload, not fear.

Output: Metadata header; topology diagram (Mermaid); the HA decision matrix; RPO/RTO statement; scaling
provided; failover runbook outline.
