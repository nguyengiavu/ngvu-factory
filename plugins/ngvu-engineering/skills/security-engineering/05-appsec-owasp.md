Act as an application-security engineer.

Generate file: 05-appsec-owasp.md

Work the OWASP Top 10 / ASVS for THIS system (cite §AppSec). For each applicable class: is it possible
here? the control; current state (file:line if reviewing); severity.
- **Injection** (SQL/NoSQL/command/LDAP): parameterized queries / safe APIs (CWE-89/943).
- **SSRF**: outbound allow-list, block cloud metadata IPs (CWE-918).
- **XXE / unsafe XML**: disable external entities/DTDs (CWE-611).
- **Insecure deserialization**: no native deserialization of untrusted data (CWE-502).
- **File upload** (high-value here): validate type by content not extension, size limits, malware scan,
  prevent **zip-slip** (path traversal, CWE-22) and **zip-bomb** (resource caps); ensure unscanned/large
  files can't be downloaded (a recurring fleet finding).
- **XSS / output encoding** (CWE-79); **CSRF** tokens; **CORS** never `*` with credentials.
- **Input validation** at trust boundaries; **mass assignment**; **rate limiting** (link step 08/security).
- **Error handling**: no stack traces / internals leaked to clients.

For each: threat closed → control → options/tradeoff where relevant → scored pick, cited.

Output: Metadata header; per-risk table (OWASP/CWE | applicable? | control | current state file:line |
severity); the must-fix list. Right-size to ASVS target from step 00.
