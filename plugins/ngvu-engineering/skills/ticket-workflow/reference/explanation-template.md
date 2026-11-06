# <TICKET-KEY> — <short title>

> Delivery write-up produced by the `ticket-workflow` skill. Fill every section; delete a section only if
> genuinely N/A (say so rather than leaving it blank). Keep it concrete — link files and cite evidence.

- **Jira**: <https://example.atlassian.net/browse/VUNG-XXXXXX>
- **Pull request**: <https://github.com/nguyengiavu/<service>/pull/XXXX>
- **Service / repo**: `<service>`  ·  **Branch**: `<team>/vung-XXXXXX-<slug>`  ·  **Base**: `master` (or the epic branch)
- **Type**: Bug | Story | Task   ·   **Author**: <you>   ·   **Date**: <YYYY-MM-DD>

## 1. Ticket summary
What the ticket asks for, in plain English, and **why** (the business need).

## 2. Acceptance criteria
- [ ] AC1 …
- [ ] AC2 …
(Mirror the ticket; mark each as met in §5.)

## 3. Analysis
- Affected area of the service (entry points → service → store), and where it sits among the services it calls
  and is called by (per the dependency manifest, e.g. `catalog-info.yaml`).
- Root cause (for bugs): the cause→symptom chain.
- Constraints/assumptions, and the blast radius (one service? one tenant? a shared contract?).

## 4. Approach & key decisions
- The approach taken and **why**; alternatives considered and rejected.
- Contract/API changes, data-shape changes (SQL migration or Mongo backfill), auth/tenancy (authorization,
  tenant scoping, secrets), config, resilience (timeouts, retries, fallbacks).
- Link any `adr/` entries created. Note anything intentionally deferred.

## 5. What changed
| File / component | Change | Why |
|---|---|---|
| `path/...` | … | … |

- Public contract impact: <none | breaking → version/compat plan> (and the dependency manifest updated?).
- Data/migration: <none | backfill job, tolerant-reader steps, rollback>.

**Acceptance criteria status:** AC1 ✅ (how) · AC2 ✅ (how) · …

## 6. Testing
- Unit: <what, where> — result.
- Integration (Testcontainers with the real database, WireMock for other services): <what> — result.
- Build/verify: the service's build and verify commands — <pass/fail + notable output>.
- Manual / `/verify`: <what was exercised in the running service>.
- `/code-review` & `/security-review`: <key findings + resolution>.

## 7. Risks & rollout
- Risks and mitigations (perf, multi-tenant, backward compat, messaging and secrets dependencies).
- Rollout/rollback: deploy through the pipeline and the deploy repo; rollback = redeploy previous image tag /
  revert the manifest bump. Feature flag? Migration ordering vs deploy?
- Follow-ups / tech debt left behind.

## 8. Links & references
- Related tickets, dependent services (`dependsOn`), docs, ADRs.
