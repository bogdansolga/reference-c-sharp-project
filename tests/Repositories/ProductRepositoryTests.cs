using Api.Domain;
using Api.Repositories;
using FluentAssertions;
using Xunit;

namespace Tests.Repositories;

// Mirrors the Vitest product-repository.test.ts (real DB). Products require a section (FK).
public class ProductRepositoryTests
{
    private static async Task<int> SeedSectionAsync(TestDb db)
    {
        var section = await new SectionRepository(db.Context).CreateAsync(new Section { Name = "Electronics" });
        return section.Id;
    }

    [Fact]
    public async Task Create_then_FindById_returns_product()
    {
        using var db = new TestDb();
        var sectionId = await SeedSectionAsync(db);
        var repo = new ProductRepository(db.Context);

        var created = await repo.CreateAsync(
            new Product
            {
                Name = "Laptop",
                Price = 999.99,
                SectionId = sectionId,
            }
        );
        var found = await repo.FindByIdAsync(created.Id);

        found.Should().NotBeNull();
        found!.Name.Should().Be("Laptop");
        found.Price.Should().Be(999.99);
    }

    [Fact]
    public async Task FindAll_returns_created_products()
    {
        using var db = new TestDb();
        var sectionId = await SeedSectionAsync(db);
        var repo = new ProductRepository(db.Context);
        await repo.CreateAsync(new Product { Name = "Laptop", Price = 999.99, SectionId = sectionId });

        (await repo.FindAllAsync()).Should().ContainSingle();
    }

    [Fact]
    public async Task Update_changes_price()
    {
        using var db = new TestDb();
        var sectionId = await SeedSectionAsync(db);
        var repo = new ProductRepository(db.Context);
        var created = await repo.CreateAsync(new Product { Name = "Laptop", Price = 999.99, SectionId = sectionId });

        var updated = await repo.UpdateAsync(created.Id, name: null, price: 899.99, sectionId: null);

        updated.Should().NotBeNull();
        updated!.Price.Should().Be(899.99);
        updated.Name.Should().Be("Laptop");
    }

    [Fact]
    public async Task Delete_removes_product()
    {
        using var db = new TestDb();
        var sectionId = await SeedSectionAsync(db);
        var repo = new ProductRepository(db.Context);
        var created = await repo.CreateAsync(new Product { Name = "Laptop", Price = 999.99, SectionId = sectionId });

        await repo.DeleteAsync(created.Id);

        (await repo.FindAllAsync()).Should().BeEmpty();
    }
}
