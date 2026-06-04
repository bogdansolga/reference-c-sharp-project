# reference-c-sharp-project

A small, production-shaped **ASP.NET Core 8** reference app — the C# port of
[`reference-typescript-project`](../reference-typescript-project), used as the hands-on
showcase for the *Mastering Claude Code* course.

Same domain (products + sections + auth + an AI chat widget), same layered architecture,
ASP.NET Core idioms. It deliberately ships the things that make Claude Code productive on a
real codebase: a layered design, a `CLAUDE.md`, deterministic git-hook guardrails, and a
`.claude/` configuration (commands, a skill, hooks, MCP).

## Stack

| Layer | Technology |
|-------|-----------|
| Backend | ASP.NET Core 8 Minimal API (`api/`) |
| Data | EF Core + SQLite (created & seeded on startup) |
| Validation | FluentValidation |
| Auth | cookie session + path-based authorization middleware |
| Tests | xUnit + NSubstitute + FluentAssertions |
| Frontend | Next.js 16 reused from the TS reference (`web/`), chat on Anthropic/Claude |
| Guardrails | git hooks + architecture checks (bash **and** PowerShell) |

## Prerequisites

```bash
nb install --cask dotnet-sdk@8     # .NET 8 SDK (only system dependency)
# Bun is needed for the web/ frontend (already common on dev machines)
```
Set `ANTHROPIC_API_KEY` (copy `web/.env.example` → `web/.env.local`) for the chat widget.

## Run

```bash
# 1) Backend — http://localhost:5099  (creates + seeds the SQLite DB on first run)
cd api && dotnet run

# 2) Frontend — http://localhost:3000  (proxies /api/* to the backend)
cd web && bun install && bun dev
```

Open http://localhost:3000. Log in with `admin/admin` (full access) or `user/user`
(read-only). The API is also usable directly:

```bash
curl http://localhost:5099/api/v1/section          # 401 — auth required
curl -c jar -X POST http://localhost:5099/api/auth/login \
  -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin"}'
curl -b jar http://localhost:5099/api/v1/section    # 200
```

## Test & verify

```bash
dotnet test                              # 27 xUnit tests
dotnet build && dotnet format --verify-no-changes
./scripts/check-architecture.sh          # layer-boundary guardrail (or .ps1)
```

## Guardrails

Install the git hooks so the architecture is enforced on every commit/push:

```bash
./scripts/git-hooks/install.sh           # macOS / Linux / Git Bash
pwsh ./scripts/git-hooks/install.ps1     # Windows without WSL
```

See [`CLAUDE.md`](./CLAUDE.md) for the full architecture, conventions, and the guardrail rules.
