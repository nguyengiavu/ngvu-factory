Act as a CTO consolidating a standardized maturity scorecard.

Generate file:
09-maturity-scorecard.md

Read all pillar reports written so far (00–08). Do NOT re-analyze — consolidate their scores into one
standardized, defensible scorecard using the rubric in SKILL.md (0–5 capability maturity).

Produce:
1. **Scorecard table** — one row per pillar:
   | Pillar | Current (0–5) | Target (0–5) | Gap | Weight | Top evidence (file:line) | Severity |
   Pillars: Scalability, Reliability/SRE, Performance, Security, Data architecture, Observability,
   Delivery/DevOps, Operability/Cost.
2. **Weighting** — assign weights from the step-00 criticality profile (e.g. financial data → Security &
   Data weighted higher). State the weights explicitly.
3. **Overall maturity** — weighted current vs weighted target; also give the simple `score10 = level x 2`
   mapping per pillar so it lines up with any system-analysis verdict.
4. **Maturity radar / bar** — an ASCII or Mermaid visualization of Current vs Target per pillar.
5. **Biggest gaps** — top pillars by Gap x Weight, which feed the roadmap (step 10).
6. **Right-sizing audit** — confirm no pillar's Target was set higher than the system warrants; flag any
   recommendation elsewhere that risks over-engineering.

Output: Metadata header (date, overall current/target), the tables and visualization, and a one-paragraph
honest read of where the system sits relative to "world-class for its size".
