using Api.Dtos;
using FluentValidation;

namespace Api.Validation;

/// <summary>Mirrors TS `createSectionSchema`.</summary>
public class CreateSectionValidator : AbstractValidator<CreateSectionDto>
{
    public CreateSectionValidator() => RuleFor(x => x.Name).NotEmpty();
}

/// <summary>Mirrors TS `updateSectionSchema` (name optional, but non-empty when present).</summary>
public class UpdateSectionValidator : AbstractValidator<UpdateSectionDto>
{
    public UpdateSectionValidator() =>
        When(x => x.Name is not null, () => RuleFor(x => x.Name).NotEmpty());
}
