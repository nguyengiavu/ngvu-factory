Act as a threat modeler.

Generate file: 01-threat-model.md

Using the assets, boundaries, and actors from step 00, build the threat model (cite §Threat modeling):
- **STRIDE per trust boundary**: for each boundary, enumerate Spoofing / Tampering / Repudiation / Info
  disclosure / DoS / Elevation threats that apply. Table: boundary | STRIDE category | threat | example.
- **Abuse cases / attack trees** for the highest-value assets: how would an attacker actually reach them?
  (e.g. "read another company's salary file" → enumerate IDs on an unscoped endpoint).
- **Rank threats**: likelihood x impact → CRITICAL/HIGH/MEDIUM/LOW. Note which are already mitigated vs
  open.
- **Map to later steps**: each ranked threat names which step (02–08) designs its control — so no threat
  is left without an owner.

Be concrete and system-specific; avoid generic checklists. Distinguish observed (seen in code/config)
from inferred.

Output: Metadata header; STRIDE-per-boundary table; abuse cases/attack trees (Mermaid where useful);
ranked threat register (threat | severity | status | control-step). This drives the whole engagement.
