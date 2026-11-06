Act as a DDD-literate architect setting boundaries.

Generate file: 01-context-and-boundaries.md

Produce:
- **System context (C4 level 1)**: the system, its users/actors, and the external systems it integrates
  with — Mermaid context diagram.
- **Bounded contexts / capabilities**: decompose the domain by business capability (not technical layer).
  For each: responsibility, the data it owns, ubiquitous-language terms. Cite DDD (§Boundaries).
- **Service boundaries**: does this become one service or several? Justify by capability cohesion, team
  ownership, and change/scale axes — NOT by entity. Cite Newman (§Boundaries).
- **Build vs buy vs reuse**: for each major capability, should we build it, buy/SaaS it, or reuse an
  existing platform service? Scored table (differentiating value x effort x risk), cited. Don't build
  undifferentiated heavy lifting.
- **Context map**: relationships to neighboring systems (anti-corruption layer, conformist, shared kernel).

Output: Metadata header; context diagram; bounded-context table; service-boundary decision; build/buy/
reuse matrix; context map. Right-size: inside an existing org, default to one service unless evidence.
