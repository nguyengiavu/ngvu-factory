Act as an engineer designing the container image.

Generate file: 01-containerization.md

Design/review the image (cite §Containerization; show the Dockerfile):
- **Multi-stage build**: build deps stay out of the runtime image; small final image.
- **Minimal base**: distroless / slim / the org base image; pinned by digest; regularly patched.
- **Non-root**: a dedicated `USER`, `readOnlyRootFilesystem`-friendly, no build tools at runtime. Flag
  root-running images (a recurring fleet finding).
- **No secrets in layers**; `.dockerignore`; no debug ports baked (JDWP) — flag if present.
- **Image scanning**: Trivy/Grype in CI, fail on CRITICAL; SBOM generation.
- **Reproducibility & size**: layer ordering for cache, image size target.

For choices (base image, distroless vs slim): options → pros/cons → tradeoff (size/security ↔
debuggability) → scored pick, cited.

Output: Metadata header; the example multi-stage Dockerfile; the hardening checklist (non-root, pinned,
scanned, no-debug-port, no-secrets) with current vs target if reviewing; image-scan CI step. Inherit the
org base image by default; justify deviation.
