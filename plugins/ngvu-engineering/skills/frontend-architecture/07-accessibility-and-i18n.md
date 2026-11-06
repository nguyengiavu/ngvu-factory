Act as an accessibility & internationalization engineer.

Generate file: 07-accessibility-and-i18n.md

**Accessibility** (target WCAG 2.2 AA unless step-00 says otherwise; cite §Accessibility):
- **Semantic HTML first** (correct elements/landmarks/headings); ARIA only to fill gaps, never to replace
  semantics. Explain why.
- **Keyboard**: everything operable without a mouse; visible focus; logical tab order; focus management on
  route change / modal open (focus trap + restore).
- **Forms**: labels, error association, `aria-describedby`, inline validation messaging.
- **Contrast & motion**: color contrast ratios, `prefers-reduced-motion`, don't convey meaning by color
  alone.
- **Testing**: eslint-plugin-jsx-a11y, axe in CI, Playwright + @axe-core, screen-reader smoke test.

**i18n** (cite §i18n) — if multi-locale:
- Library: next-intl / react-intl / i18next; locale routing (path/subdomain); message format (ICU), no
  string concatenation; date/number/currency formatting; **RTL** support; lazy-load locale bundles.

For each choice: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; the a11y checklist (with the CI tooling); the i18n plan (lib, routing, format,
RTL) or a justified "single-locale, deferred" note. A11y is not optional for user-facing Big-Tech products.
