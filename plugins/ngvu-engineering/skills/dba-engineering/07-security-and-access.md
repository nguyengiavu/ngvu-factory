Act as a security-focused DBA.

Generate file: 07-security-and-access.md

Design data-tier security (cite engine-comparison §Security):
- **Authentication**: PG (`scram-sha-256`, certs), Mongo (SCRAM/x.509), MSSQL (logins/AAD); no shared
  superuser for apps.
- **Authorization / least privilege**: roles/`GRANT`; separate app vs admin vs read-only accounts; scope
  to the minimum. **Row-Level Security** (PG, MSSQL) for multi-tenant row scoping; Mongo RBAC + (Enterprise)
  field-level access.
- **Encryption**: in transit (TLS everywhere); at rest (PG `pgcrypto`/cloud TDE, Mongo WiredTiger/CSFLE,
  MSSQL **TDE** + Always Encrypted for columns; field-level for the most sensitive).
- **Secrets**: DB credentials in a manager (Vault/KMS) with rotation; never in code/config/images.
- **Auditing**: `pgaudit` / Mongo auditing / SQL Server Audit on sensitive access; tamper-evident, no
  secrets in logs.
- **Network**: private networking, no public exposure, IP allow-lists / private endpoints.

For each: options → pros/cons → tradeoff → scored pick, cited. Map controls to the data classification
(PII/financial → strict, e.g. column encryption + RLS + audit).

Output: Metadata header; authn plan; role/privilege matrix; encryption-at-rest/in-transit plan; secrets
plan; audit plan; network plan. Right-size to data sensitivity.
