using Api.Domain;
using Api.Domain.Errors;
using Api.Dtos;
using Api.Repositories;
using Api.Services;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Tests.Services;

// Mirrors the Vitest product-service.test.ts (repositories mocked).
public class ProductServiceTests
{
    private readonly IProductRepository _products = Substitute.For<IProductRepository>();
    private readonly ISectionRepository _sections = Substitute.For<ISectionRepository>();
    private readonly ProductService _service;

    public ProductServiceTests() => _service = new ProductService(_products, _sections);

    [Fact]
    public async Task CreateProduct_throws_when_section_not_found()
    {
        _sections.FindByIdAsync(999).Returns((Section?)null);

        var act = () => _service.CreateProductAsync(new CreateProductDto("Test", 10, 999));

        await act.Should().ThrowAsync<NotFoundException>().WithMessage("Section not found");
    }

    [Fact]
    public async Task CreateProduct_succeeds_when_section_exists()
    {
        _sections.FindByIdAsync(1).Returns(new Section { Id = 1, Name = "Electronics" });
        _products
            .CreateAsync(Arg.Any<Product>())
            .Returns(new Product
            {
                Id = 1,
                Name = "Test",
                Price = 10,
                SectionId = 1,
            });

        var result = await _service.CreateProductAsync(new CreateProductDto("Test", 10, 1));

        result.Should().BeEquivalentTo(new ProductResponse(1, "Test", 10, 1));
    }

    [Fact]
    public async Task GetProductById_throws_when_not_found()
    {
        _products.FindByIdAsync(999).Returns((Product?)null);

        var act = () => _service.GetProductByIdAsync(999);

        await act.Should().ThrowAsync<NotFoundException>().WithMessage("Product not found");
    }
}
