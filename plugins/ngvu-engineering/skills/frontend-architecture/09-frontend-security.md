Act as a frontend security engineer.

Generate file: 09-frontend-security.md

Design frontend security (cite §Frontend security; compose security-engineering for depth):
- **XSS** (the #1 FE risk): rely on React's escaping; ban/scrutinize `dangerouslySetInnerHTML` (sanitize
  with DOMPurify if unavoidable); validate/encode any HTML from users/CMS. Explain the threat.
- **CSP** (Content-Security-Policy): a strict policy (nonce/hash for scripts) to contain XSS; plus
  **secure headers** (HSTS, X-Content-Type-Options, Referrer-Policy, frame-ancestors/X-Frame-Options).
  Show the header set.
- **Auth token storage**: prefer **httpOnly + Secure + SameSite cookies** over `localStorage` (which is
  XSS-exfiltratable) — scored tradeoff (XSS exposure ↔ CSRF need ↔ SPA convenience). **CSRF**: SameSite +
  anti-CSRF token for cookie auth.
- **Secrets**: only `NEXT_PUBLIC_*` (or `VITE_*`) reach the client — audit that no API key/secret is bundled.
- **Server Actions / RSC / route handlers**: treat as server endpoints — authenticate, authorize, and
  **validate input** (Zod); never trust the client. (Recurring backend-style gap on the FE.)
- **Dependencies**: `npm audit` / SCA in CI, lockfile committed, watch for malicious packages.
- **Other**: clickjacking (frame-ancestors), open redirects, `target="_blank"` → `rel="noopener"`.

For each: threat → control → options/tradeoff → scored pick → WHY, cited.

Output: Metadata header; threat→control table; the CSP + secure-header set; token-storage decision matrix;
secrets-in-bundle audit; Server-Action security rule; dependency-scan plan.
