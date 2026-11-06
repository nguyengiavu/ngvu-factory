Act as a DevOps/Platform engineer applying DORA and Google release practice.

Generate file:
07-delivery-devops.md

Benchmark against `reference/bigtech-patterns.md` §07 (DORA/trunk-based CI/CD; progressive delivery
canary/blue-green + automated rollback; feature flags decouple deploy from release; DORA metrics;
IaC + GitOps).

Examine (cite file:line / pipeline config):
- **Pipeline**: build/test/deploy stages; are tests a hard gate or bypassable? Hotfix path — does it skip
  tests/safeguards? Branching model.
- **Progressive delivery**: canary/blue-green, automated rollback, health-gated promotion — or
  all-at-once deploys?
- **Feature flags**: deploy decoupled from release? Kill switches for risky features?
- **DORA metrics**: deploy frequency, lead time, change-fail rate, MTTR — measured?
- **IaC / GitOps**: infra in code, declarative sync, drift control; secrets in pipeline.
- **Quality gates**: SonarQube/coverage/SCA wired and correct (right project key, fails the build)?

For EACH gap: (1) current state file:line; (2) target practice + source (§07); (3) why it matters —
deployment risk, rollback time, change failure blast radius; severity; (4) recommended target level +
action.

Output: Metadata header (current/target level), gap list, comparison table, Missing Information (e.g.
external trigger definitions, the K8s/GitOps repo). Score 0–5 (Current / Target / Gap).
