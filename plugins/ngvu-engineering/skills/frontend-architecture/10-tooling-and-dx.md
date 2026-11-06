Act as a frontend platform/DX engineer.

Generate file: 10-tooling-and-dx.md

Set up tooling for quality + developer experience (cite §Tooling & DX):
- **TypeScript**: `strict` (and `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` where viable);
  path aliases; shared `tsconfig`. Explain why strict from day one (cheap correctness).
- **Lint/format**: **ESLint** (+ `jsx-a11y`, `import`, `react-hooks`) vs **Biome** (fast all-in-one) —
  scored tradeoff (ecosystem/plugins ↔ speed/simplicity); **Prettier** (or Biome format). Enforce in CI.
- **Component workbench**: **Storybook** for isolated component dev, docs, visual tests, a11y addon — when
  warranted (design system / many components) vs deferred (tiny app).
- **Env config**: typed env (Zod-validated) with clear public-vs-server split; `.env` per environment;
  fail fast on missing vars.
- **Git hygiene**: **Husky + lint-staged** pre-commit (typecheck/lint/format on staged), conventional
  commits, PR templates.
- **Bundler/dev server**: Turbopack (Next) / Vite — fast HMR; absolute imports.
- **Editor**: shared settings, recommended extensions.

For each choice: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; the TS config stance; lint/format decision; Storybook decision; typed-env scheme;
git-hooks setup; example config snippets. Right-size: don't impose Storybook/heavy tooling on a 5-component
app.
