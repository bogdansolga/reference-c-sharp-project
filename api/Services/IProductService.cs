using Api.Dtos;

namespace Api.Services;

/// <summary>Business logic for products. Mirrors the TS `productService`.</summary>
public interface IProductService
{
    Task<List<ProductResponse>> GetAllProductsAsync();
    Task<ProductResponse> GetProductByIdAsync(int id);
    Task<ProductResponse> CreateProductAsync(CreateProductDto data);
    Task<ProductResponse> UpdateProductAsync(int id, UpdateProductDto data);
    Task DeleteProductAsync(int id);
}
