using Api.Domain;

namespace Api.Repositories;

/// <summary>Data access for products. Mirrors the TS `productRepository`.</summary>
public interface IProductRepository
{
    Task<List<Product>> FindAllAsync();
    Task<Product?> FindByIdAsync(int id);
    Task<Product> CreateAsync(Product product);
    Task<Product?> UpdateAsync(int id, string? name, double? price, int? sectionId);
    Task DeleteAsync(int id);
}
