# Approval Policy

Human approval is **mandatory** before any of the following. The AI may *prepare* the change (plan,
diff, dry-run, command list, rollback plan) but must **not execute** it until a human says go.

## Always requires approval
- Production deploy or traffic shift (Kubernetes rollout, image tag bump in `example_deploy`).
- Production rollback / redeploying a previous image tag.
- Cutting a release: `maven-release-plugin` onto `released_branch`, `release_candidate.sh` / `release.sh`
  (they push branches/tags). The normal path — Cloud Build on a reviewed `master` commit — needs none.
- IAM / service-account change; Vault secret creation, rotation, or read-for-export.
- Making a GCS bucket or any resource public.
- Prod Pub/Sub admin: deleting, replaying (`seek`) or updating a topic or subscription (ack deadline,
  dead-letter, retention, push config). Deleting loses unacked messages; replay reprocesses them.
- Destructive DB/collection migration (drop, irreversible type change, un-backfilled rename), or an
  index build on a **large production tenant** (can block writes / spike CPU).
- Auth / authorization change (`@PermissionAllowed`, MP JWT config, tenant-isolation logic).
- Disabling a security check, a quality gate, or tests to "get it through".

## Never, even with approval — hand it to a human
- Merging or approving any PR, or merging into `master`/`develop` locally: teammates review and
  approve on GitHub and a human merges.
- Pushing `master`/`develop`/`release/*` directly (every change reaches `master` through a reviewed PR).
- **Touching PROD outside the deploy process.** While investigating, implementing, reviewing or
  testing a ticket, the AI never connects to, queries or changes a production resource: no DB
  session (not even a read-only `SELECT count(*)`), no `kubectl` get/exec/port-forward against a prod
  cluster, no Cloud Logging read of a prod project, no Pub/Sub, Vault, GCS, IAM or config action on
  prod. A change reaches PROD only through the deploy process: reviewed PR → a human merges to
  `master` → Cloud Build → human-approved image tag bump in `example_deploy` (Flyway migrations run
  at pod startup). Investigate on dev/test. A PROD fact the ticket needs (row count, `indisvalid`,
  a prod log line) is asked of the person who runs that deploy or has PROD access, or stays `UNKNOWN`.
  This overrides every read-only allowance elsewhere in these rules (`safe-command-policy.md`
  auto-safe list, the GCP log section of `cost-token-policy.md`).

Pushing a `vung-<n>` ticket/epic branch to origin is pre-approved — see `safe-command-policy.md`
§ ngvu branch → PR flow.

## Approval request format
```
## Action
## Risk (LOW/MEDIUM/HIGH/CRITICAL) + why
## Blast radius (services / tenants / data affected)
## Dry-run evidence
## Rollback plan
## Explicit approval needed from: <role/person>
```

## Rule
If in doubt about the risk tier, escalate up, not down. Never infer approval from a prior, different
approval — approval is per-action. See [`GLOBAL-RULES.md`](GLOBAL-RULES.md) §5 and the
`ai-governance-control` skill.
