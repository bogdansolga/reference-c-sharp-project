using Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace Api.Data;

/// <summary>
/// Idempotent seed. Mirrors the TS `seed.ts` (same sections/products, same order).
/// Runs on startup (like the TS instrumentation hook) after EnsureCreated.
/// </summary>
public static class Seeder
{
    public static async Task SeedAsync(AppDbContext db)
    {
        if (await db.Sections.AnyAsync())
        {
            return;
        }

        var electronics = new Section { Name = "Electronics" };
        var books = new Section { Name = "Books" };
        var clothing = new Section { Name = "Clothing" };
        db.Sections.AddRange(electronics, books, clothing);
        await db.SaveChangesAsync();

        db.Products.AddRange(
            new Product { Name = "Laptop", Price = 999.99, SectionId = electronics.Id },
            new Product { Name = "Smartphone", Price = 699.99, SectionId = electronics.Id },
            new Product { Name = "TypeScript Handbook", Price = 29.99, SectionId = books.Id },
            new Product { Name = "Clean Code", Price = 39.99, SectionId = books.Id },
            new Product { Name = "T-Shirt", Price = 19.99, SectionId = clothing.Id }
        );
        await db.SaveChangesAsync();
    }
}
