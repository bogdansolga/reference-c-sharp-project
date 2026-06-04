# CLAUDE.md

Guidance for Claude Code when working in this repository. It is the **C# (.NET 8) port**
of `../reference-typescript-project`, used as the hands-on showcase for the *Mastering
Claude Code* course. Same domain and architecture, ASP.NET Core idioms.

## What this project does

A small two-tier app: a REST API for managing **products** grouped into **sections**, with
cookie auth and a Claude-backed chat widget. CRUD lives at `/api/v1/{product,section}`; login at
`/api/auth/*`. `/api/v1` requires a session (writes require ADMIN). SQLite is created and seeded
on startup (3 sections, 5 products; users `admin/admin` and `user/user`). The `web/` UI renders
the lists server-side from the API and hosts the chat widget. It exists to be a realistic,
small codebase for demonstrating how to drive and protect a real project with Claude Code — the
guardrails in `scripts/` are as much the point as the features.

**How to use it:** run the API (`cd api && dotnet run`) and the web (`cd web && bun dev`), log in,
and browse. Extend it with `/add-endpoint`. Verify with `dotnet test` + the `scripts/check-*`
guardrails (installed as git hooks). Full run/test commands below.

## Layout

```
api/    ASP.NET Core 8 Minimal API — all backend logic (the C# port)
web/    Reused Next.js frontend — proxies /api/* to the C# API
scripts/ Git-hook guardrails + architecture checks (bash + PowerShell)
```

## Commands

| Task | Command |
|------|---------|
| Run API | `cd api && dotnet run` (Kestrel on http://localhost:5099) |
| Run web | `cd web && npm run dev` (Next.js on http://localhost:3000, proxies to :5099; `bun dev` also works) |
| Build | `dotnet build` (from repo root, builds the solution) |
| Test | `dotnet test` |
| Single test | `dotnet test --filter "FullyQualifiedName~ProductServiceTests"` |
| Format | `dotnet format` |
| Format check | `dotnet format --verify-no-changes` |
| Web type+lint | `cd web && npm run verify:all` (or `bun run verify:all`) |
| Install hooks | `./scripts/git-hooks/install.sh` (bash) or `install.ps1` (Windows/pwsh) |

Local prerequisites: **.NET 8 SDK** (`nb install --cask dotnet-sdk@8`), a **Node package
manager** for `web/` — **npm** (with Node.js) by default, **Bun** optional (`PM=bun`) — and
`ANTHROPIC_API_KEY` for the chat widget. No DB migration step — tables are created and seeded
on startup.

## Architecture

ASP.NET Core 8 layered REST API over SQLite (EF Core). Same request flow as the TS reference:

```
Endpoint (api/Endpoints/*)        HTTP, calls services only
  → FluentValidation (api/Validation/)
  → Service (api/Services/*)       business logic, throws domain exceptions
  → Repository (api/Repositories/*) EF Core data access only
  → AppDbContext (api/Data/) → SQLite
```

### Key patterns

- **Error handling**: domain exceptions (`NotFoundException` → 404, `DomainValidationException`
  → 400) caught by `ExceptionHandlingMiddleware` (mirrors the TS `handleError`). Endpoints have
  no try/catch.
- **Authorization**: `AuthorizationMiddleware` (port of the TS `proxy.ts`) — `/api/v1/*` needs a
  session (401), writes need ADMIN (403); `/api/auth/*` is open.
- **Auth**: cookie session via `SessionAuth`. httpOnly `session` cookie stores `{id, username,
  role}` JSON. Test users: `user/user` (USER), `admin/admin` (ADMIN).
- **DB init**: `db.Database.EnsureCreated()` + `Seeder` on startup in `Program.cs`. Table/column
  names match the TS Drizzle schema (`sections`, `products`, `section_id`).
- **DTOs**: records in `api/Dtos/`. Minimal-API JSON is camelCase (matches the TS contract).
- **Frontend**: `web/` is the TS frontend reused as-is; `next.config.ts` rewrites `/api/v1` +
  `/api/auth` to the C# API. Chat (`/api/chat`) stays in `web/` on Anthropic/Claude.

### Guardrails (scripts/)

Git hooks enforce the architecture. `pre-commit` (build + format + arch checks on staged
files) and `pre-push` (full build + tests + checks). Config-driven via `arch-checks.conf`:
- **check-architecture** — layer import boundaries (endpoints can't import repositories/Data; services can't import Data).
- **check-validators** — no inline FluentValidation in endpoints/services (must live in `api/Validation/`).
- **check-deep-architecture** — repo purity, domain errors, no repo imports in endpoints.

Both **bash** (`*.sh`) and **PowerShell** (`*.ps1`) variants exist; Windows users without WSL
run `install.ps1`. Bypass once with `--no-verify`.

## Do NOT

- Import repositories or `AppDbContext` from endpoints — go through services.
- Import `AppDbContext` from services — go through repositories.
- Define FluentValidation validators inline — put them in `api/Validation/`.
- Throw generic `Exception` in services — use domain exceptions.
- Add a DB migration step — this reference uses `EnsureCreated` + seed on startup.
- Skip the hooks — run `verify` before committing; the guardrails are the point.
