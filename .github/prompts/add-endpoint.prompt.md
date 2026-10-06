---
name: add-endpoint
description: 'Add a new REST resource following the layered architecture (endpoint → service → repository), test-first'
argument-hint: 'ResourceName and fields, e.g. Supplier name:string email:string'
agent: agent
tools: ['read', 'search', 'edit', 'execute']
---
<!--
Prompt file: the Copilot port of .claude/commands/add-endpoint.md. Run as /add-endpoint in VS Code chat.
VS Code only (deprecated for Agent Host sessions); for the CLI, turn it into a skill in .github/skills/.
Source: https://code.visualstudio.com/docs/copilot/customization/prompt-files
-->
Add a new resource **${input:resource:ResourceName}** with fields **${input:fields:fields, e.g. name string, price decimal}** to the C# API. Follow the layered architecture exactly and mirror the existing Product/Section code; do not introduce new patterns.

Implement, in order. For steps 4 and 5, write the test first (mirror `tests/Repositories/ProductRepositoryTests.cs` and `tests/Services/ProductServiceTests.cs`), run it, watch it fail, then write the code.

1. **Domain**: `api/Domain/<Resource>.cs`; map it in `api/Data/AppDbContext.cs` (snake_case table and column names, like `products` / `section_id`).
2. **DTOs**: `api/Dtos/<Resource>Dtos.cs` with `Create<Resource>Dto`, `Update<Resource>Dto` and `<Resource>Response` records.
3. **Validation**: `api/Validation/<Resource>Validators.cs` (FluentValidation; never inline).
4. **Repository**: `api/Repositories/I<Resource>Repository.cs` + `<Resource>Repository.cs` (EF Core only; no ASP.NET usings).
5. **Service**: `api/Services/I<Resource>Service.cs` + `<Resource>Service.cs` (depends on repositories, never `AppDbContext`; throws `NotFoundException` / `DomainValidationException`).
6. **Endpoint**: `api/Endpoints/<Resource>Endpoints.cs` with `MapGroup("/api/v1/<resource>")`; register the endpoints and the DI in `api/Program.cs`.

Then verify, and show me the results:

```bash
dotnet build && dotnet test && ./scripts/check-architecture.sh && ./scripts/check-validators.sh
```

Do not commit or push; I review the diff first.
