# api — AGENTS.md

Guidance for AI coding agents working in the **`api/`** module. See the
[root AGENTS.md](../AGENTS.md) for the project overview and architecture rules that this
module enforces.

ASP.NET Core 8 Minimal API over SQLite (EF Core). Backend logic lives here; the `web/` tier
proxies to it.

## Run / test

```bash
cd api && dotnet run          # Kestrel on http://localhost:5099
dotnet build                  # from repo root, builds the solution
dotnet test                   # xUnit suite (in tests/)
dotnet format                 # apply formatting (--verify-no-changes to check)
```

DB is created and seeded on startup (`EnsureCreated` + `Seeder`) — no migration step.

## Layers (request flow)

```
Endpoints/*      HTTP wiring, calls services only — no try/catch, no data access
  → Validation/*    FluentValidation validators (never inline)
  → Services/*      business logic, throws domain exceptions
  → Repositories/*  EF Core data access only
  → Data/AppDbContext → SQLite
```

## Key files

- `Program.cs` — DI, middleware pipeline, endpoint mapping, DB init.
- `Http/ExceptionHandlingMiddleware.cs` — maps `NotFoundException` → 404, `DomainValidationException` → 400.
- `Http/AuthorizationMiddleware.cs` — `/api/v1/*` needs a session (401); writes need ADMIN (403); `/api/auth/*` open.
- `Auth/SessionAuth.cs` — httpOnly `session` cookie storing `{id, username, role}` JSON.
- `Domain/Errors/*` — domain exceptions. `Dtos/*` — request/response records (camelCase JSON).

## Conventions

- New resource = endpoint + service (+ interface) + repository (+ interface) + validators + DTOs, in that order.
- Throw domain exceptions (`NotFoundException`, `DomainValidationException`), never generic `Exception`.
- Object-style EF inserts; table/column names mirror the TS Drizzle schema (`sections`, `products`, `section_id`).

## Do NOT

- Import repositories or `AppDbContext` from endpoints — go through services.
- Import `AppDbContext` from services — go through repositories.
- Put FluentValidation validators inline — they live in `Validation/`.
- Add try/catch in endpoints — the middleware handles errors.
- Add a DB migration step — `EnsureCreated` + seed only.
