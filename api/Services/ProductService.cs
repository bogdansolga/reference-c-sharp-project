using Api.Domain;
using Api.Domain.Errors;
using Api.Dtos;
using Api.Http;
using Api.Repositories;

namespace Api.Services;

/// <summary>
/// Mirrors the TS `productService`. Validates the section exists on create/update and
/// throws domain errors (never a generic Exception — enforced by the deep-architecture check).
/// </summary>
public class ProductService(IProductRepository products, ISectionRepository sections) : IProductService
{
    public async Task<List<ProductResponse>> GetAllProductsAsync()
    {
        var all = await products.FindAllAsync();
        return all.Select(ToResponse).ToList();
    }

    public async Task<ProductResponse> GetProductByIdAsync(int id)
    {
        var product = await products.FindByIdAsync(id) ?? throw new NotFoundException(Messages.ProductNotFound);
        return ToResponse(product);
    }

    public async Task<ProductResponse> CreateProductAsync(CreateProductDto data)
    {
        _ = await sections.FindByIdAsync(data.SectionId) ?? throw new NotFoundException(Messages.SectionNotFound);
        var created = await products.CreateAsync(
            new Product
            {
                Name = data.Name,
                Price = data.Price,
                SectionId = data.SectionId,
            }
        );
        return ToResponse(created);
    }

    public async Task<ProductResponse> UpdateProductAsync(int id, UpdateProductDto data)
    {
        _ = await products.FindByIdAsync(id) ?? throw new NotFoundException(Messages.ProductNotFound);

        if (data.SectionId is not null)
        {
            _ = await sections.FindByIdAsync(data.SectionId.Value)
                ?? throw new NotFoundException(Messages.SectionNotFound);
        }

        var updated =
            await products.UpdateAsync(id, data.Name, data.Price, data.SectionId)
            ?? throw new NotFoundException(Messages.ProductNotFound);
        return ToResponse(updated);
    }

    public async Task DeleteProductAsync(int id)
    {
        _ = await products.FindByIdAsync(id) ?? throw new NotFoundException(Messages.ProductNotFound);
        await products.DeleteAsync(id);
    }

    private static ProductResponse ToResponse(Product p) => new(p.Id, p.Name, p.Price, p.SectionId);
}
