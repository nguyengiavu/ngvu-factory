---
name: ngvu-pod-health
description: "Read-only health check of workloads in one Kubernetes namespace: pod status and restarts, deployment readiness, recent Warning events. Use for \"check pod health\", \"is the rollout healthy\", or the health step of /ngvu-factory verify. Never restarts, scales, edits or deletes anything. For log content use ngvu-flow-logs."
---

# ngvu-pod-health

A snapshot of whether the workloads of one environment are up: are pods Running and Ready, did they
restart, did the deployment reach its desired replicas, and what Kubernetes warned about lately.

**Read-only.** Only `kubectl get`. No `rollout restart`, `scale`, `delete`, `exec`, `apply`, `patch`.
If a fix is needed, describe it and let a human run it.

## Before you run it
1. Env (`dev`, `test`, ...) = the namespace. Workloads = deployment name prefixes, lower-case with `-`
   (`my_service` -> `my-service`). Confirm both with the user; if a workload is not found, ask, do not guess.
2. Name the cluster context explicitly (`KUBE_CONTEXT`). The script refuses to use whatever context
   happens to be active, so it cannot hit the wrong cluster.
3. `prod` needs the user's explicit yes and `CONFIRM_PROD=1`.

## Run
```bash
ENV=dev KUBE_CONTEXT=my-dev-cluster SERVICES="example-docs example-core" bash "<skill dir>/pod_health.sh"
```

| Variable | Default | Meaning |
|---|---|---|
| `ENV` | required | Namespace |
| `KUBE_CONTEXT` | required | kubectl context to use |
| `SERVICES` | all in the namespace | Space-separated name prefixes to keep |
| `KF_DRY_RUN` | unset | `1` prints the kubectl commands and does nothing else |

## Judge it
| Finding | Verdict |
|---|---|
| All pods `Running`, ready `n/n`, restarts unchanged, deployment `READY == DESIRED == UPDATED` | **HEALTHY** |
| Deployment short of replicas, `UPDATED` < `DESIRED` after minutes, or restarts rising | **DEGRADED**: say which workload and since when |
| `CrashLoopBackOff`, `ImagePullBackOff`, `Pending`, `OOMKilled`, or no pod at all | **UNHEALTHY** |
| Warning events only from before the change you are checking | note it, not a verdict on its own |

Report the verdict first, then the table rows that justify it. A restart count alone is not a
failure: compare with the age of the pod and with the deploy time. Do not paste secrets or env values
if you ever look further (`secret-data-guard`).

## Requirements
`kubectl` with read access to the namespace; Git Bash on Windows.
