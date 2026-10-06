---
name: 'xUnit tests'
description: 'Use when creating or updating tests in the tests/ project.'
applyTo: 'tests/**/*.cs'
---
<!--
Path-scoped instructions for tests/.
Source: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
Source: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
-->
# xUnit Tests

- xUnit (`[Fact]`, `[Theory]`) + FluentAssertions (`.Should()`) + NSubstitute (`Substitute.For<T>()`); don't add other test libraries.
- Folders mirror `api/`: `tests/Services/`, `tests/Repositories/`, `tests/Validation/`; namespaces `Tests.<Folder>`; class `<ClassUnderTest>Tests`.
- Test names: `Method_condition_or_result`, e.g. `CreateProduct_throws_when_section_not_found`.
- Service tests substitute the repository interfaces (`IProductRepository`, `ISectionRepository`) and build the service in the constructor.
- Repository and validator tests use a real SQLite DB: `using var db = new TestDb();` then `db.Context`. Don't use the EF InMemory provider.
- Assert domain errors with `await act.Should().ThrowAsync<NotFoundException>().WithMessage("...")`.
- Write the failing test first; run it with `dotnet test --filter "FullyQualifiedName~<Class>Tests"`; then run the full `dotnet test`.
