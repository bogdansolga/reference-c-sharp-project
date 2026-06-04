# Spec: Migrate reference-c-sharp-project from .NET 8 to .NET 10

## Context

The project currently targets `net8.0` across both `api/Api.csproj` and `tests/Tests.csproj`.
.NET 9 reached end-of-support in May 2026, so the correct upgrade path is directly to **.NET 10**
(LTS, released November 2025, supported until November 2028). NuGet packages are also pinned at
versions matching the .NET 8 era and need to be refreshed.

User decision: keep **FluentAssertions at v6.12.2** (skip v7 due to its commercial license change).

---

## Changes

### 1. TargetFramework — both csproj files
- `api/Api.csproj`: `<TargetFramework>net8.0</TargetFramework>` → `net10.0`
- `tests/Tests.csproj`: `<TargetFramework>net8.0</TargetFramework>` → `net10.0`

### 2. Add `global.json` at repo root
Pin the SDK so all developers and CI use the same toolchain:
```json
{
  "sdk": {
    "version": "10.0.100",
    "rollForward": "latestMinor"
  }
}
```
No breaking changes. Verify the installed SDK version with `dotnet --version` before writing.

### 3. NuGet package updates

#### api/Api.csproj

| Package | From | To | Breaking? |
|---|---|---|---|
| `Microsoft.EntityFrameworkCore.Sqlite` | 8.0.11 | **10.x.x** | ⚠️ See below |
| `FluentValidation.DependencyInjectionExtensions` | 11.11.0 | latest **11.x** | No — minor/patch within v11 |

#### tests/Tests.csproj

| Package | From | To | Breaking? |
|---|---|---|---|
| `Microsoft.EntityFrameworkCore.Sqlite` | 8.0.11 | **10.x.x** | ⚠️ Same as above |
| `Microsoft.NET.Test.Sdk` | 17.11.1 | latest stable | No |
| `xunit` | 2.9.2 | latest **2.x** | No — stay on v2; v3 is a major rewrite |
| `xunit.runner.visualstudio` | 2.8.2 | latest **2.x** matching xunit | No |
| `NSubstitute` | 5.3.0 | latest **5.x** | No |
| `FluentAssertions` | 6.12.2 | **no change** | — (user decision) |

> **EF Core versioning rule:** EF Core major version must match the .NET target version.
> `net10.0` requires `Microsoft.EntityFrameworkCore.Sqlite` `10.x.x` in both projects.
> Use the same patch version in both csproj files.

---

## ⚠️ Potentially Breaking Changes

### A. EF Core 8 → 10 (crossing two majors: 8→9→10)

**Low risk for this project** given the simple two-table schema, but flag these:

1. **EF Core 9: LINQ query translation changes** — Some queries that previously evaluated
   client-side now evaluate server-side (or vice versa). Affects `FindAllAsync` / `AnyAsync`
   calls. Risk: LOW — the queries in this project are simple `ToListAsync()` and `FindAsync()`.

2. **EF Core 9: `ExecuteUpdate` / `ExecuteDelete`** — API changed. Risk: **NONE** — not used
   in this project.

3. **EF Core 9: Owned entity type column mapping** — Changes to how `HasColumnType` works for
   owned types. Risk: **NONE** — no owned types in this project.

4. **EF Core 10: Complex type default mapping** — New complex type support. Risk: **NONE** —
   entities are plain POCOs.

5. **`OnDelete(DeleteBehavior.Restrict)`** — Verify after upgrade that the FK constraint between
   `products` and `sections` still generates the correct SQLite schema. Run `dotnet test` to
   confirm repository integration tests pass.

### B. ASP.NET Core .NET 9/10 changes

1. **Cookie `SameSite` default** — Unchanged (`Lax`). `SessionAuth.cs` explicitly sets
   `SameSite.Strict`, so no impact.

2. **`IResult` / Minimal API** — The `Results.Created`, `Results.Ok`, `Results.NotFound` APIs
   are stable across .NET 8–10. No change expected.

3. **`System.Text.Json` defaults** — `JsonSerializerDefaults.Web` (used in `SessionAuth.cs`)
   is stable. No change expected.

4. **`RequestDelegate` middleware pattern** — The custom `ExceptionHandlingMiddleware` and
   `AuthorizationMiddleware` use the standard constructor-injection pattern, which is unchanged.

### C. xUnit v2 → staying on v2 (confirmed safe)
Upgrading to xUnit v3 would require changing `[Fact]` test method signatures in async tests
and adopting a new configuration format. Out of scope for a .NET version migration. Staying
on latest v2 is fully compatible with .NET 10.

---

## Files to Modify

- `api/Api.csproj` — TargetFramework + 2 package versions
- `tests/Tests.csproj` — TargetFramework + 5 package versions
- `global.json` — **new file** at repo root (SDK pin)

No application code changes are expected. If EF Core 10 introduces a compile error or
test failure, that will be addressed during verification.

---

## Verification

Run in order after making the changes:

1. `dotnet build` — must succeed with zero warnings (`TreatWarningsAsErrors=true`)
2. `dotnet test` — all 27 tests must pass (especially `ProductRepositoryTests` and
   `SectionRepositoryTests` which exercise EF Core directly via `TestDb`)
3. `cd api && dotnet run` — start the API, verify seed data loads (`GET /api/v1/product`)
4. `dotnet format --verify-no-changes` — confirm no formatting drift

If `dotnet build` fails after the package update, the most likely cause is an EF Core 10
API removal. Check the compiler errors and fix the relevant file in `api/Data/`.
