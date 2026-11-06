# 06 — Deploy, environments & test data

---

## 1. Pipeline

| Repo | Jenkins job | Cloud Build | Docker image |
|---|---|---|---|

<!-- Check each repo's `cloudbuild.yaml`: some repos default to
     `_SKIP_TESTS: "true"`, so your tests will NOT run in the pipeline.
     In that case, run `mvn verify` locally and attach the result to the PR. -->

After the build, Cloud Build clones `example_deploy` and runs:
`bump_image_tag.sh <branch> <COMMIT_SHA> <service-name> [env] [file]`

## 2. Environments

`infra/example_deploy/kubernetes-overlays/`

| Overlay | Purpose | Used for this ticket |
|---|---|---|
| `env-dev` | Development | |
| `env-dev-staging` | Pre-check | |
| `env-test` | QA / UAT | |
| `env-performance` | Performance | |
| `env-prod` | Production | |

Related manifests:

```
infra/example_deploy/kubernetes/<service>/k8s.yaml
infra/example_deploy/kubernetes-overlays/env-<env>/<service>/patch-configmap.yaml
infra/example_deploy/kubernetes/cronjob/<service>/
```

## 3. Related cronjobs / schedulers

<!-- Many ngvu flows only run on a schedule (the 10th, the 20th, monthly).
     Record how to trigger them by hand so you do not wait for that day when testing. -->

| CronJob | Schedule | Calls endpoint |
|---|---|---|

```bash
# dev/test only; on prod this is CRITICAL and needs an approver
kubectl -n <ns> create job manual-<name>-$(date +%s) --from=cronjob/<cronjob-name>
```

## 4. Control endpoints (to set up scenarios)

| Method | Path | Used to |
|---|---|---|

## 5. Deploy tasks per environment

### Dev
- [ ]

### Test (UAT)
- [ ]

### Production
- [ ]

## 6. Test data

### Sample tenants

| Purpose | Tenant | Notes |
|---|---|---|

### Way A — set up with SQL

```sql
```

### Way B — set up through the API

### Way C — fastest setup

<!-- Always look for a way to reach the target state WITHOUT rerunning the whole business
     process. There is often an endpoint that writes directly into the tracking table. -->

## 7. Observability & alerts

| Metric / log | Purpose | Alert threshold |
|---|---|---|

<!-- Use a log prefix like `[FEATURE_NAME]`, as the existing jobs do, so you can grep/correlate. -->

## 8. Rollback

| Situation | Action | Time |
|---|---|---|

<!-- State whether there is a DB migration. No migration = rollback is just
     changing the image tag or turning off the flag, and that is worth saying. -->

## 9. Operations handover checklist

- [ ] Support guide
- [ ] Manual handling procedure when needed
- [ ] Dashboard / alert
- [ ] Runbook
