---
name: 'API endpoints'
description: 'Use when adding or changing Minimal API endpoints in api/Endpoints.'
applyTo: 'api/Endpoints/**/*.cs'
---
<!--
Path-scoped instructions for api/Endpoints/. See also api/AGENTS.md.
Source: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
Source: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
-->
# API Endpoints

- One static class per resource, `<Resource>Endpoints`, with a `Map<Resource>Endpoints(this IEndpointRouteBuilder app)` extension; register it in `Program.cs`.
- Group routes with `app.MapGroup("/api/v1/<resource>")`; ids are `{id:int}`.
- Inject the service interface (`I<Resource>Service`) and `IValidator<TDto>`; validate with `RequestValidation.ValidateAsync(validator, body)` and return its result when it is not null.
- Never use `I*Repository`, `AppDbContext` or `using Api.Data` / `using Api.Repositories` here; `scripts/check-architecture.sh` fails the commit.
- No try/catch: `ExceptionHandlingMiddleware` maps `NotFoundException` → 404 and `DomainValidationException` → 400.
- Return `Results.Ok(...)`, `Results.Created($"/api/v1/<resource>/{id}", dto)` or `Results.NoContent()`; return DTOs from `api/Dtos/`, never entities.
- Authorization is path-based in `AuthorizationMiddleware`; don't add per-endpoint auth checks.
