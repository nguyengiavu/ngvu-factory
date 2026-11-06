Act as a frontend architect defining structure.

Generate file: 02-project-structure-and-monorepo.md

Decide (cite §Project structure & monorepo):
- **Repo strategy**: single app repo vs **monorepo** (Turborepo / Nx). Scored: do you have multiple apps +
  shared packages (design system, utils, config)? If one small app → single repo (monorepo is
  over-engineering). State the tradeoff (consistency/sharing ↔ tooling complexity) and the why.
- **Folder architecture**: feature-based / colocation (group UI+logic+tests+styles by feature) over
  type-based. Show the proposed tree. Cite colocation principle.
- **Component architecture**: presentational vs container, server vs client components, the layering
  (ui primitives → composed components → features → routes/pages), and the dependency rule (features don't
  import each other's internals).
- **Design system package**: is it a separate package with its own build + Storybook + versioning? When
  yes (shared across apps/teams) vs no (single app — keep it a folder).
- **Shared packages**: types, API client, config (eslint/tsconfig), utils.

For each: options → pros/cons → tradeoff → scored pick → WHY, cited.

Output: Metadata header; repo-strategy decision; the folder tree (feature-based); component-layering rule;
design-system-package decision; shared-package list. Right-size to team & app count.
