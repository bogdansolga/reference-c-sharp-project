---
name: layered-architecture
description: Use when adding or modifying API features in this C# project — enforces the endpoint → service → repository layering, validation placement, and error-handling conventions that the git-hook guardrails check.
---

# Layered Architecture (reference-c-sharp-project)

This project enforces a strict layering. The git hooks in `scripts/` will block commits that
violate it, so follow these rules from the start.

## The layers

```
Endpoint (api/Endpoints)  → Service (api/Services) → Repository (api/Repositories) → AppDbContext (api/Data)
```

- **Endpoints**: HTTP only. Map routes, inject `IValidator<T>` for writes, call **services**.
  Never reference `Api.Repositories` or `Api.Data`. No try/catch — `ExceptionHandlingMiddleware`
  maps domain exceptions to status codes.
- **Services**: business logic. Depend on **repository interfaces**, never `AppDbContext`.
  Throw domain exceptions (`NotFoundException`, `DomainValidationException`) — never `new Exception(...)`.
- **Repositories**: EF Core data access only. No `Microsoft.AspNetCore.*` or `Api.Http` usings.
- **Validation**: FluentValidation validators live in `api/Validation/` and are injected — never
  defined inline in endpoints/services.

## Authorization

`/api/v1/*` requires a session (401) and ADMIN for writes (403), enforced in
`AuthorizationMiddleware` (the port of the TS `proxy.ts`). `/api/auth/*` is open.

## Conventions

- DTOs are `record` types in `api/Dtos/`; JSON is camelCase (matches the frontend contract).
- DB tables/columns use snake_case (`products`, `section_id`) via Fluent config in `AppDbContext`.
- No migrations — `EnsureCreated` + `Seeder` run on startup.

## Verify before committing

```bash
dotnet build && dotnet test
./scripts/check-architecture.sh && ./scripts/check-validators.sh && ./scripts/check-deep-architecture.sh
```

To scaffold a new resource the right way, use the `/add-endpoint` command.
