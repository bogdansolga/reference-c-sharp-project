using Api.Dtos;
using FluentValidation;

namespace Api.Validation;

/// <summary>Mirrors TS `createProductSchema`.</summary>
public class CreateProductValidator : AbstractValidator<CreateProductDto>
{
    public CreateProductValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.Price).GreaterThan(0).WithMessage("Price must be positive");
        RuleFor(x => x.SectionId).GreaterThan(0).WithMessage("Section ID is required");
    }
}

/// <summary>Mirrors TS `updateProductSchema` (partial — validate only provided fields).</summary>
public class UpdateProductValidator : AbstractValidator<UpdateProductDto>
{
    public UpdateProductValidator()
    {
        When(x => x.Name is not null, () => RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required"));
        When(x => x.Price is not null, () => RuleFor(x => x.Price!.Value).GreaterThan(0).WithMessage("Price must be positive"));
        When(
            x => x.SectionId is not null,
            () => RuleFor(x => x.SectionId!.Value).GreaterThan(0).WithMessage("Section ID is required")
        );
    }
}
