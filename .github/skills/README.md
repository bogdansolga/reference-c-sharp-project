# Skills: Superpowers 6.4.1 (Pinned Copy)

These 8 folders are copied unchanged from [obra/superpowers](https://github.com/obra/superpowers) **v6.4.1** (MIT, © Jesse Vincent; see `LICENSE` here), with two edits:

1. `using-superpowers/references/` is removed: it holds per-harness tool notes, and none is for Copilot. `using-superpowers/SKILL.md` still names those files; ignore the mention.
2. The plugin namespace is dropped (`superpowers:writing-plans` → `writing-plans`), so cross-references match Copilot skill names.

| Skill | Use in the course |
|---|---|
| `using-superpowers` | The bootstrap; the line in `copilot-instructions.md` replaces its session-start hook |
| `brainstorming` | Part 3 lab; answer **no** to the visual companion (it needs Node and a browser) |
| `writing-plans` | Called by brainstorming; ship both |
| `executing-plans` | Inline plan execution; the lab default. Its scripts need bash (Git Bash or WSL on Windows) |
| `subagent-driven-development` | Demo only; keep it next to `executing-plans`, which calls its `scripts/` |
| `test-driven-development` | RED-GREEN-REFACTOR |
| `systematic-debugging` | 4-phase root cause analysis |
| `verification-before-completion` | Evidence before "done" |

Install: copy the folders (with `LICENSE`) to `<repo>/.github/skills/` or `~/.copilot/skills/`. In the CLI, run `/skills reload` then `/skills list`; in VS Code, type `/` in chat.

Sources: https://code.visualstudio.com/docs/copilot/customization/agent-skills · https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills · the course note `copilot-training/docs/superpowers-on-copilot.md`.
