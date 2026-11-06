Act as a principal engineer making the design defensible.

Generate file: 09-tradeoffs-and-evaluation.md

This is the step the user most wants — the explicit, honest tradeoff record.

Produce:
- **Alternatives considered**: for the 2–4 biggest decisions across steps 03–08 (e.g. SQL vs NoSQL,
  sync vs async, monolith vs services, strong vs eventual consistency), present each as: Option A vs B (vs C)
  | pros | cons | tradeoff axis | which NFR it serves/sacrifices | **chosen + why the others lost**.
- **Consolidated decision matrix**: rows = the big decisions, columns = the step-00 NFR weights, cells =
  how each chosen option scores; show the weighted total. Make the weighting explicit.
- **Known weaknesses & risks** of the chosen design — be honest about what it does badly and when it
  would need to change (the next redesign trigger).
- **Cost sketch**: rough run-cost drivers (compute/storage/egress) and the biggest lever.
- **What we deliberately did NOT do** (over-engineering avoided), with why.

Cite building blocks throughout. 

Output: Metadata header; alternatives tables; consolidated matrix; weaknesses/risks; cost sketch;
over-engineering-avoided list. This section should let a reviewer challenge and understand every choice.
