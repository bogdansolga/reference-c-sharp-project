# Copilot Setup (Mastering Copilot Labs)

The GitHub Copilot counterpart of `.claude/`, tailored to this repo. Shared templates live in the course `copilot-config` repo.

| Path | What it is | Lab |
|---|---|---|
| `copilot-instructions.md` | Stack, commands, architecture, do-nots; ends with the Superpowers bootstrap line | Part 2 |
| `instructions/api-endpoints.instructions.md` | `applyTo: api/Endpoints/**/*.cs` | Part 2 |
| `instructions/tests.instructions.md` | `applyTo: tests/**/*.cs` | Part 2 |
| `prompts/add-endpoint.prompt.md` | `/add-endpoint` in VS Code (port of `.claude/commands/add-endpoint.md`) | Parts 2-3 |
| `agents/reviewer.agent.md` | Read-only reviewer (`read`, `search` only) with the architecture checklist | Part 3 |
| `hooks/format-cs.json` + `hooks/scripts/format-cs.sh` | postToolUse: `dotnet format` on edited `api/` and `tests/` C# files | Part 3 |
| `skills/` | 8 Superpowers skills, pinned to 6.4.1 (MIT; see `skills/README.md`) | Part 3 |
| `lsp.json` | `csharp-ls` for the Copilot CLI (`/lsp test csharp`) | Part 4 |

Notes:
- The hook is bash only (macOS, Linux, the cloud agent; Git Bash on Windows). It needs `dotnet` on `PATH` (or `/usr/local/share/dotnet`) and exits silently without it. VS Code hooks are Preview.
- `csharp-ls`: `dotnet tool install --global csharp-ls`; current versions need the .NET 10 SDK to run, while this repo targets .NET 8.
- The git hooks in `scripts/git-hooks/` stay the guaranteed gate; the Copilot hook is a convenience.
- Bank rules: no `--allow-all-tools` on client code; do not rely on content exclusion in the CLI or agent mode; vet MCP servers by hand (the repo's `.mcp.json` is the Claude Code config).

Sources (checked 2026-10-06):
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions · https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- https://code.visualstudio.com/docs/copilot/customization/prompt-files
- https://code.visualstudio.com/docs/copilot/customization/custom-agents · https://docs.github.com/en/copilot/reference/custom-agents-configuration
- https://code.visualstudio.com/docs/copilot/customization/agent-skills
- https://docs.github.com/en/copilot/reference/hooks-reference · https://code.visualstudio.com/docs/copilot/customization/hooks · https://code.visualstudio.com/docs/agents/reference/hooks-reference
- https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers · https://github.com/razzmatazz/csharp-language-server
