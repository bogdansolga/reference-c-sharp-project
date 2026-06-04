using Api.Domain;
using Api.Repositories;
using FluentAssertions;
using Xunit;

namespace Tests.Repositories;

// Mirrors the Vitest section-repository.test.ts (real DB).
public class SectionRepositoryTests
{
    [Fact]
    public async Task FindAll_returns_empty_when_no_sections()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);

        (await repo.FindAllAsync()).Should().BeEmpty();
    }

    [Fact]
    public async Task Create_then_FindById_returns_section()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);

        var created = await repo.CreateAsync(new Section { Name = "Electronics" });
        var found = await repo.FindByIdAsync(created.Id);

        found.Should().NotBeNull();
        found!.Name.Should().Be("Electronics");
    }

    [Fact]
    public async Task FindById_returns_null_when_missing()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);

        (await repo.FindByIdAsync(9999)).Should().BeNull();
    }

    [Fact]
    public async Task Update_changes_name()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);
        var created = await repo.CreateAsync(new Section { Name = "Old" });

        var updated = await repo.UpdateAsync(created.Id, "Updated");

        updated.Should().NotBeNull();
        updated!.Name.Should().Be("Updated");
    }

    [Fact]
    public async Task Update_returns_null_when_missing()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);

        (await repo.UpdateAsync(9999, "Updated")).Should().BeNull();
    }

    [Fact]
    public async Task Delete_removes_section()
    {
        using var db = new TestDb();
        var repo = new SectionRepository(db.Context);
        var created = await repo.CreateAsync(new Section { Name = "Electronics" });

        await repo.DeleteAsync(created.Id);

        (await repo.FindAllAsync()).Should().BeEmpty();
    }
}
