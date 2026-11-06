# 10 — Deployment, test data, rollback

## 1. Branches, pipeline, environments

### 1.1 Branches (checked with git, not assumed)

| Repo | Epic branch | On origin? | Base | Evidence (`branch-status.sh`) |
|---|---|---|---|---|

<!-- Epic branch per the factory: <team>/vung-<epic>/EPIC-<slug>; child: <team>/vung-<epic>/vung-<n>-<slug>. -->

### 1.2 Pipeline · 1.3 Environment matrix

## 2. Migration

## 3. Test data on DEV (configuration checklist + read-only SQL for someone with access to run)

## 4. Triggering a cronjob / job by hand on DEV

## 5. Work needing approval before PROD

<!-- Each HIGH/CRITICAL item follows the format of rules/approval-policy.md:
## Action / ## Risk / ## Blast radius / ## Dry-run evidence / ## Rollback plan / ## Explicit approval needed from -->

## 6. Feature flags & rollout (separate `enabled` from `enforcing` to run in shadow mode)

## 7. Rollback

## 8. After deployment — what must be visible (logs, metrics, numbers)
