<!--
Repo-wide Copilot instructions (VS Code, CLI, cloud agent, code review). Loaded on every request; keep it lean.
The full guide is AGENTS.md (also read by Copilot); module rules are in .github/instructions/.
Source: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
Source: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
-->
# reference-c-sharp-project

A small products-and-sections REST API (ASP.NET Core 8 Minimal API) with cookie auth, plus a Next.js 16 front end in `web/` that proxies `/api/*` to it. It is the reference codebase for the Mastering Copilot course; the guardrails in `scripts/` matter as much as the features.

## Stack

- C# on .NET 8 (`net8.0`, nullable on, `TreatWarningsAsErrors` in `api/`), ASP.NET Core Minimal API
- EF Core + SQLite; the DB is created and seeded on startup (`EnsureCreated` + `Seeder`), no migrations
- FluentValidation; cookie session auth (`SessionAuth`) + `AuthorizationMiddleware`
- Tests: xUnit + NSubstitute + FluentAssertions in `tests/` (SQLite in-memory via `tests/TestDb.cs`)
- `web/`: Next.js 16, TypeScript, Biome; npm by default, Bun optional

## Commands (from the repo root)

- Build: `dotnet build`
- Test: `dotnet test`; one class: `dotnet test --filter "FullyQualifiedName~ProductServiceTests"`
- Format: `dotnet format`; check: `dotnet format --verify-no-changes`
- Architecture checks: `./scripts/check-architecture.sh`, `./scripts/check-validators.sh`, `./scripts/check-deep-architecture.sh` (`.ps1` on Windows)
- Run: `cd api && dotnet run` (http://localhost:5099); web: `cd web && npm run dev`; both: `./scripts/dev.sh`
- Web checks: `cd web && npm run verify:all`

## Architecture

`Endpoints/*` → `Validation/*` (FluentValidation) → `Services/*` → `Repositories/*` → `Data/AppDbContext` → SQLite.

- Endpoints call services only: no repositories, no `AppDbContext`, no try/catch.
- Services never use `AppDbContext`; they throw `NotFoundException` / `DomainValidationException`, never `Exception`.
- Validators live in `api/Validation/`, never inline.
- DTOs are records in `api/Dtos/`; JSON is camelCase. Table and column names are snake_case (`products`, `section_id`).
- A new resource: domain → DTOs → validators → repository (+ interface) → service (+ interface) → endpoint + DI in `Program.cs` → tests.
- `/api/v1/*` needs a session (401); writes need ADMIN (403). Seed users: `admin/admin`, `user/user`.

## Do Not

- Add a DB migration step, a new package or a new pattern without asking.
- Skip or bypass the git hooks (`--no-verify`); fix what they report.
- Run `git push`; the user pushes after review.
- Commit `.env`, `web/.env.local` or any key (`ANTHROPIC_API_KEY`).

## Skills (Superpowers)

Before any response or action, check `.github/skills/` for a skill whose description matches the task and follow it exactly (announce "Using <skill> to <purpose>"). Building something → `brainstorming` first; a bug → `systematic-debugging` first. For plans, prefer `executing-plans`. User instructions override skills.
