Act as a design-systems engineer choosing styling & components.

Generate file: 05-styling-and-design-system.md

Decide (cite §Styling & design system):
- **Styling approach**: **Tailwind CSS** (utility-first, zero-runtime, consistent, scales — con: verbose
  markup) vs **CSS Modules** (scoped plain CSS, zero-runtime) vs **vanilla-extract** (typed zero-runtime
  CSS-in-TS) vs **CSS-in-JS** (styled-components/Emotion — dynamic theming but **runtime cost + not
  RSC-compatible by default**, declining for SSR/RSC). Scored matrix; explain WHY, and specifically warn
  against runtime CSS-in-JS if using RSC/SSR. Cite the "breaking up with CSS-in-JS" rationale.
- **Component layer**: unstyled-accessible primitives (**Radix UI**) + **shadcn/ui** (own the code) for
  control, vs batteries-included (**MUI / Mantine / Chakra**) for speed. Tradeoff: control/bundle/a11y ↔
  speed-to-build. Scored.
- **Design tokens**: color/spacing/typography/radius scales as the single source of truth; light/dark
  theming; how tokens feed Tailwind config or CSS variables.
- **Responsive & layout**: mobile-first, breakpoints, container queries; consistent spacing scale.

For each: options → pros/cons → tradeoff → scored pick → WHY, cited. Show a token example + a sample
component.

Output: Metadata header; styling-approach decision matrix; component-library decision; design-token scheme
+ theming; responsive strategy. Right-size to whether a real design system is needed.
