using Api.Data;
using Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace Api.Repositories;

/// <summary>
/// EF Core data access only — no HTTP concerns (enforced by the deep-architecture check).
/// Mirrors the TS `productRepository`.
/// </summary>
public class ProductRepository(AppDbContext db) : IProductRepository
{
    public async Task<List<Product>> FindAllAsync() => await db.Products.AsNoTracking().ToListAsync();

    public async Task<Product?> FindByIdAsync(int id) =>
        await db.Products.AsNoTracking().FirstOrDefaultAsync(p => p.Id == id);

    public async Task<Product> CreateAsync(Product product)
    {
        db.Products.Add(product);
        await db.SaveChangesAsync();
        return product;
    }

    public async Task<Product?> UpdateAsync(int id, string? name, double? price, int? sectionId)
    {
        var product = await db.Products.FirstOrDefaultAsync(p => p.Id == id);
        if (product is null)
        {
            return null;
        }

        if (name is not null)
        {
            product.Name = name;
        }

        if (price is not null)
        {
            product.Price = price.Value;
        }

        if (sectionId is not null)
        {
            product.SectionId = sectionId.Value;
        }

        await db.SaveChangesAsync();
        return product;
    }

    public async Task DeleteAsync(int id)
    {
        var product = await db.Products.FirstOrDefaultAsync(p => p.Id == id);
        if (product is not null)
        {
            db.Products.Remove(product);
            await db.SaveChangesAsync();
        }
    }
}
