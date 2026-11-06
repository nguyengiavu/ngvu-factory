Act as a Security Architect scoping the engagement.

Generate file: 00-scope-and-assets.md

Establish the security baseline that targets everything else:
- **Assets & data classification**: enumerate the data the system holds/processes; classify each
  public / internal / PII / financial / regulated. The most sensitive asset sets the bar.
- **Trust boundaries**: where untrusted input/users meet trusted code (internet→edge, service→service,
  app→datastore, tenant→tenant). Diagram them (Mermaid). These are where step-01 threats live.
- **Actors**: legitimate users/roles/services AND adversaries (external attacker, malicious tenant,
  insider, compromised dependency).
- **Compliance scope**: which regimes apply (OWASP ASVS level target — L1/L2/L3; PCI-DSS if card data;
  GDPR for EU PII; SOC 2). Cite `reference/security-controls.md`.
- **Existing posture** (if reviewing): what's already in place; gather read-only, cite file:line; never
  quote secret values.

Output: Metadata header (project, file, date, confidence); asset/classification table; trust-boundary
diagram; actor list; compliance scope + ASVS target; Assumptions/Missing Information. This sets the
right-sizing for every control.
