# Third-party notices

ngvu-factory credits the projects below.

## Reference packs

The files under `plugins/ngvu-engineering/skills/*/reference/` are the author's own summaries.
They name their sources but quote no text from them.

## software-factory-claude-code

ngvu-factory started as a fork of this project and keeps its design ideas: the loop of one
orchestrator skill and seven agents, file hand-offs with a verdict on line 1, the bounded builder
loop, parallel reviewers with WAIT FOR ALL, worktree-per-job and atomic claims, and the idea of a
polling dashboard.

No upstream text remains. Compared line by line with the upstream folder at commit `c326b80`,
the two share only Claude Code agent front-matter (`tools:`, `model:`) and a standard HTML head.

- Source: https://github.com/zazencodes/zazencodes-season-3/tree/main/src/software-factory-claude-code
- License: none published (no LICENSE file in the repository or in that folder)
- Copyright: © Alexander Galea

## Further references

Watched while designing ngvu-factory; no text or code is copied from it.

- "I Built a Self-Improving Software Factory", Eric Tech (YouTube):
  https://www.youtube.com/watch?v=aggJvNZxfKA
