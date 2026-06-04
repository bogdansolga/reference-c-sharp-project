# Claude Code Exercises — C# Reference Project

A hands-on ladder for driving this ASP.NET Core 8 codebase with Claude Code. Start with
reading/analysis, progress to writing, refactoring, and a full layered feature. Each
exercise notes the Claude Code feature it practices.

> Tip: prefer **plan mode** for the bigger exercises, review the diff before accepting, and
> let the git-hook guardrails (`scripts/`) catch architecture violations.

---

## 1. Explain a file (read)
**Practices:** agentic search.
```
Explain what api/Data/AppDbContext.cs does and how it maps to the SQLite schema.
```
Observe: does it identify the EF Core entity config and the snake_case table/column mapping?

## 2. Find functionality (read)
**Practices:** codebase navigation.
```
Where is authentication and authorization handled in this project?
```
Observe: does it find `api/Auth/SessionAuth.cs` and `api/Http/AuthorizationMiddleware.cs`,
and explain the cookie session + the /api/v1 vs /api/auth rules?

## 3. Understand the architecture (read)
**Practices:** whole-repo reasoning, CLAUDE.md.
```
Describe this project's architecture and layering. What do the scripts/ guardrails enforce?
```
Observe: endpoint → service → repository → EF Core; the three `check-*` scripts.

## 4. Code review (analyze)
**Practices:** review, the code-reviewer agent.
```
Review api/Services/ProductService.cs for correctness and error handling. Respect existing patterns.
```

## 5. Add documentation (write)
**Practices:** targeted edits.
```
Add XML doc comments to the public members of api/Repositories/SectionRepository.cs.
```

## 6. Write a test (write)
**Practices:** following test conventions.
```
Add xUnit tests for api/Services/ProductService.cs UpdateProduct, mirroring ProductServiceTests. Mock repositories with NSubstitute.
```
Observe: does it follow the existing test style and cover success + not-found cases?

## 7. Refactor (write, behavior-preserving)
**Practices:** minimal diffs.
```
Refactor api/Endpoints/ProductEndpoints.cs to reduce duplication in the validate-then-act flow, keeping behavior identical.
```

## 8. Add validation (write)
**Practices:** respecting the validator-location guardrail.
```
Add a rule to api/Validation/ProductValidators.cs: product name max length 100. Keep validators out of endpoints/services.
```

## 9. Add an endpoint (feature)
**Practices:** slash commands, the layered-architecture skill.
```
/add-endpoint
```
…then ask for `GET /api/v1/product/section/{sectionId}` returning products in a section,
following the layers. Observe: does it touch endpoint + service + repository correctly and
pass `./scripts/check-architecture.sh`?

## 10. Cross-layer feature (feature)
**Practices:** plan mode, multi-file change, guardrails.
```
Implement product search: repository method (name contains), service method, GET /api/v1/product/search?q=, validation, and tests. Follow the existing layered patterns.
```
Observe: correct files across all layers, edge cases (empty query), and a green
`dotnet test` + architecture checks.

---

## Prompting tips
1. **Reference exact paths** (`api/Services/ProductService.cs`).
2. **Set constraints** — "follow existing patterns", "keep behavior identical" — to avoid over-generation.
3. **One layer at a time** for clarity; let the guardrails verify the boundaries.
4. **Review the diff** before accepting; run `dotnet build && dotnet test` to confirm.
