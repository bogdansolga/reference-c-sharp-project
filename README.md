# reference-c-sharp-project

A small, production-shaped **ASP.NET Core 8** reference app — the C# port of
[`reference-typescript-project`](https://github.com/bogdansolga/reference-next-js-project), used as the hands-on
showcase for the *Mastering Claude Code* course.

Same domain (products + sections + auth + an AI chat widget), same layered architecture,
ASP.NET Core idioms. It deliberately ships the things that make Claude Code productive on a
real codebase: a layered design, a `CLAUDE.md`, deterministic git-hook guardrails, and a
`.claude/` configuration (commands, a skill, hooks, MCP).

## What it does

A two-tier app for managing **products** grouped into **sections**, with auth and an AI chat assistant:

- **REST API** (`api/`, ASP.NET Core 8) — full CRUD for products and sections at `/api/v1/*`,
  cookie-based login at `/api/auth/*`. Data is in SQLite via EF Core, created and seeded on
  first run (3 sections, 5 products). Two seeded users: `admin/admin` (full access) and
  `user/user` (read-only).
- **Authorization** — `/api/v1/*` requires a logged-in session (`401` otherwise); write
  operations (POST/PUT/DELETE) require the `ADMIN` role (`403` otherwise). `/api/auth/*` is open.
- **Web UI** (`web/`, Next.js 16) — a login page, product and section list pages (server-rendered
  from the API), and a floating **chat widget** backed by Claude (Anthropic) that answers
  questions about the API.
- **Guardrails** (`scripts/`) — git hooks that enforce the layered architecture on every commit
  and push, so the design can't silently rot.

The point isn't the CRUD — it's a realistic, small codebase that demonstrates how to drive,
extend, and protect a real project with Claude Code.

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
nb install --cask dotnet-sdk@8     # .NET 8 SDK (only required system dependency)
# The web/ frontend needs a Node package manager — npm (ships with Node.js) by
# default; Bun is optional (PM=bun ./scripts/dev.sh to use it).
```
Set `ANTHROPIC_API_KEY` (copy `web/.env.example` → `web/.env.local`) for the chat widget.

## Run

**One command** — starts both tiers, Ctrl+C stops both:

```bash
./scripts/dev.sh          # macOS / Linux / Git Bash
pwsh ./scripts/dev.ps1    # Windows (PowerShell 7+)
```

Or start the two tiers manually:

```bash
# 1) Backend — http://localhost:5099  (creates + seeds the SQLite DB on first run)
cd api && dotnet run

# 2) Frontend — http://localhost:3000  (proxies /api/* to the backend)
cd web && npm install && npm run dev        # or: bun install && bun dev
```

Open http://localhost:3000, **log in** (`admin/admin` or `user/user`), then visit Sections /
Products. The lists are empty until you log in — they are auth-gated.

> **Port note:** the web server components fetch the API directly at `API_URL` (default
> `http://localhost:5099`), so the UI works even if Next picks a port other than 3000. If your
> API runs elsewhere, set `API_URL` in `web/.env.local`.

The API is also usable directly:

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

The git hooks enforce the architecture on every commit/push. **`scripts/dev.sh` / `dev.ps1`
install them automatically on first run**, so just starting the project is enough. To install
them manually (or re-install after changing them):

```bash
./scripts/git-hooks/install.sh           # macOS / Linux / Git Bash
pwsh ./scripts/git-hooks/install.ps1     # Windows without WSL
```

## Using it in the *Mastering Claude Code* course

This repo is the live demo canvas. Each part has something concrete to drive:

- **Part 1 — Foundations:** replay an Analyze→Plan→Execute session (e.g. add an endpoint); review
  the diff; watch a guardrail hook block an unsafe edit.
- **Part 2 — Daily workflow:** read `CLAUDE.md`; run the `docs/ai-for-coding.md` exercise ladder.
- **Part 3 — Extensibility:** the git-hook guardrails the agent can't skip; the `.claude/`
  commands (`/add-endpoint`), the `layered-architecture` skill, and the PostToolUse format hook.
- **Part 4 — Power tools:** the `.mcp.json` servers; LSP for go-to-definition / find-references.

Instructor demos here; attendees practice the same moves on their own codebase. The guardrails
are stack-portable — the identical checks exist in
[`reference-typescript-project`](https://github.com/bogdansolga/reference-next-js-project) as import-path boundaries and
here as `using`-namespace boundaries.

See [`CLAUDE.md`](./CLAUDE.md) for the full architecture, conventions, and the guardrail rules.
