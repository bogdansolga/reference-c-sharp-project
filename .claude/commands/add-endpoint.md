---
description: Add a new REST resource following the layered architecture (endpoint → service → repository)
argument-hint: <ResourceName> [field:type ...]
---

Add a new resource named **$1** to the C# API, following this project's layered architecture
exactly. Respect the guardrails in `scripts/` — they will run on commit.

Fields (if provided): $ARGUMENTS

Implement, in order, mirroring the existing Product/Section code:

1. **Domain** — `api/Domain/$1.cs` entity; map it in `api/Data/AppDbContext.cs`
   (table + column names snake_case, like `products`/`sections`).
2. **DTOs** — `api/Dtos/$1Dtos.cs`: `Create$1Dto`, `Update$1Dto`, `$1Response` records.
3. **Validation** — `api/Validation/$1Validators.cs` (FluentValidation; never inline).
4. **Repository** — `api/Repositories/I$1Repository.cs` + `$1Repository.cs` (EF Core only,
   no HTTP/ASP.NET usings).
5. **Service** — `api/Services/I$1Service.cs` + `$1Service.cs` (throw `NotFoundException` /
   domain errors, never generic `Exception`; depend on repositories, not `AppDbContext`).
6. **Endpoint** — `api/Endpoints/$1Endpoints.cs` (`MapGroup("/api/v1/...")`, call the
   service only, validate via injected `IValidator<T>`). Register it in `Program.cs` and
   add the DI registrations.
7. **Tests** — xUnit in `tests/` mirroring `ProductServiceTests` / `ProductRepositoryTests`.

Then verify: `dotnet build && dotnet test && ./scripts/check-architecture.sh`.
Keep edits minimal and follow the existing file conventions — do not introduce new patterns.
