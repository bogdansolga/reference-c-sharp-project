# Handoff — Provider-agnostic AGENTS.md migration + handoff commands
_Created: 2026-06-04 12:30 UTC · Branch: main · Base: origin/main (in sync)_

## Goal
Migrate this C# reference project's agent guidance away from being Claude Code-specific so it
works with any agentic CLI (Gemini CLI, Copilot, Codex, etc.), and add a reusable pair of
session-handoff commands. Driven by an in-progress switch to another agentic CLI tool.

## State / progress
- **DONE & committed/pushed** — `main` is in sync with `origin/main`, working tree clean.
  - Root `CLAUDE.md` → `AGENTS.md` (renamed, history preserved), reworded provider-agnostic.
  - Module guides `api/AGENTS.md` and `web/AGENTS.md` created and linked from root.
  - `/handoff:create` + `/handoff:continue` commands added under `.claude/commands/handoff/`.
- **NOT verified by build/test** — all changes are docs + agent command markdown; no code
  touched, so `dotnet build`/`dotnet test` were not run. The pre-commit hook (build + arch
  checks on staged files) passed implicitly when committing.

## Files touched (this effort, all committed)
- `AGENTS.md` — renamed from CLAUDE.md; intro now addresses "AI coding agents (Claude Code,
  Gemini CLI, Copilot CLI, Codex…)"; "Claude Code tooling" section → "Agent tooling"; added
  links to the two module guides. Kept genuine product facts (chat widget runs on Claude/
  Anthropic, `ANTHROPIC_API_KEY`, the *Mastering Claude Code* course name).
- `api/AGENTS.md` — backend module guide (layers, key files, conventions, do-nots).
- `web/AGENTS.md` — frontend module guide (proxy rewrites, chat-on-Anthropic, layout, do-nots).
- `.claude/commands/handoff/create.md` — writes timestamped summary to `.claude/handoffs/`.
- `.claude/commands/handoff/continue.md` — resolves latest/given handoff, reconciles vs repo.

Commits: `153a7a9` (module agents files), `c15911e` (small improvement), `f4fc16d` (handoff cmds).

## Key decisions
- **Renamed, not duplicated** CLAUDE.md → AGENTS.md via `git mv` to preserve history.
- **Kept Claude/Anthropic mentions that are product facts** (the app's chat widget genuinely
  uses the Claude API) — only neutralized *dev-tool*-facing language.
- **Left the two OTHER CLAUDE.md files untouched** (workspace root and `_reference/CLAUDE.md`) —
  out of scope; they still reference Claude Code.
- Handoff commands are **namespaced** (`.claude/commands/handoff/`) and store **timestamped**
  files (never clobber). `continue` trusts the handoff for intent but the live repo for state.
- Handoff commands live in `.claude/` (matches existing `add-endpoint`); noted they'd need
  porting to the target CLI's command location.

## Next steps
1. Decide whether to convert the two remaining `CLAUDE.md` files (workspace root,
   `_reference/CLAUDE.md`) to provider-agnostic `AGENTS.md` — pending user direction.
2. Offered but not done: add `.claude/handoffs/` to `.gitignore` so generated handoffs stay
   untracked. Confirm with user.
3. Offered but not done: add a `CLAUDE.md → AGENTS.md` symlink so Claude Code keeps working
   during the transition (Claude Code reads CLAUDE.md, not AGENTS.md). Confirm with user.
4. When migrating to the new CLI, mirror `.claude/` setup (add-endpoint, layered-architecture
   skill, format hook, MCP servers, handoff commands) into that tool's equivalents.

## Verify
- Docs/commands only — no code build needed. To sanity-check nothing else broke:
  `dotnet build && dotnet test` (27 xUnit tests) — NOT run this session.
- Confirm commands are registered: they appear as `/handoff:create` and `/handoff:continue`
  in the CLI command list (verified — both showed up after creation).

## Open questions / risks
- The 3 "Next steps" items are user decisions, not blockers.
- No risk to code; all changes are documentation/tooling.
