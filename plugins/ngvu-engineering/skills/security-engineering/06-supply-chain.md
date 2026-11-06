Act as a software-supply-chain security engineer.

Generate file: 06-supply-chain.md

Design/review the supply chain (cite §Supply chain, OWASP A06):
- **Dependency / CVE scanning (SCA)**: tool wired into CI (OWASP Dependency-Check / Trivy / Snyk), fail
  build on CRITICAL/HIGH; audit current dependency versions for known-vulnerable/EOL components (e.g. old
  JDBC drivers, jackson, etc.) and flag the worst by name + version + risk (mark CVE specifics inferred-
  needs-scan unless certain).
- **SBOM**: generate (CycloneDX/SPDX) per build for inventory & audit.
- **Artifact integrity**: signed artifacts/images (Sigstore/cosign); verify on deploy; **SLSA** level
  target.
- **Base image provenance**: pinned by digest, minimal, regularly rebuilt/patched, scanned.
- **Build pipeline trust**: least-privilege build identity, no secrets in logs, protected branches.

For each: threat closed → options → pros/cons → scored pick, cited.

Output: Metadata header; dependency-risk table (component | version | risk | action); SCA/SBOM/signing CI
plan; base-image policy; SLSA target; gaps with severity. Right-size: at minimum, get SCA + no-known-
CRITICAL-deps; signing/SLSA-3 scale with criticality.
