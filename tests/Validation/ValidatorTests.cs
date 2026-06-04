using Api.Dtos;
using Api.Validation;
using FluentAssertions;
using Xunit;

namespace Tests.Validation;

// Mirrors the Zod schema behavior in the TS lib/types tests.
public class ValidatorTests
{
    [Fact]
    public void CreateProduct_rejects_empty_name_and_nonpositive_values()
    {
        var result = new CreateProductValidator().Validate(new CreateProductDto("", -5, 0));

        result.IsValid.Should().BeFalse();
        result.Errors.Should().HaveCount(3);
    }

    [Fact]
    public void CreateProduct_accepts_valid_input()
    {
        var result = new CreateProductValidator().Validate(new CreateProductDto("Laptop", 999.99, 1));

        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public void UpdateProduct_allows_all_fields_omitted()
    {
        var result = new UpdateProductValidator().Validate(new UpdateProductDto(null, null, null));

        result.IsValid.Should().BeTrue();
    }

    [Fact]
    public void UpdateProduct_validates_provided_fields()
    {
        var result = new UpdateProductValidator().Validate(new UpdateProductDto("", -1, 0));

        result.IsValid.Should().BeFalse();
        result.Errors.Should().HaveCount(3);
    }

    [Fact]
    public void CreateSection_requires_name()
    {
        new CreateSectionValidator().Validate(new CreateSectionDto("")).IsValid.Should().BeFalse();
        new CreateSectionValidator().Validate(new CreateSectionDto("Books")).IsValid.Should().BeTrue();
    }

    [Fact]
    public void UpdateSection_allows_omitted_name_but_rejects_empty()
    {
        new UpdateSectionValidator().Validate(new UpdateSectionDto(null)).IsValid.Should().BeTrue();
        new UpdateSectionValidator().Validate(new UpdateSectionDto("")).IsValid.Should().BeFalse();
    }
}
