using Api.Dtos;
using Api.Http;
using Api.Services;
using FluentValidation;

namespace Api.Endpoints;

/// <summary>
/// HTTP layer for sections. Mirrors the TS `/api/v1/section` routes.
/// Calls services only — never repositories (enforced by the architecture check).
/// </summary>
public static class SectionEndpoints
{
    public static void MapSectionEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/section");

        group.MapGet("", async (ISectionService service) => Results.Ok(await service.GetAllSectionsAsync()));

        group.MapGet(
            "/{id:int}",
            async (int id, ISectionService service) => Results.Ok(await service.GetSectionByIdAsync(id))
        );

        group.MapPost(
            "",
            async (CreateSectionDto body, IValidator<CreateSectionDto> validator, ISectionService service) =>
            {
                var invalid = await RequestValidation.ValidateAsync(validator, body);
                if (invalid is not null)
                {
                    return invalid;
                }

                var section = await service.CreateSectionAsync(body);
                return Results.Created($"/api/v1/section/{section.Id}", section);
            }
        );

        group.MapPut(
            "/{id:int}",
            async (int id, UpdateSectionDto body, IValidator<UpdateSectionDto> validator, ISectionService service) =>
            {
                var invalid = await RequestValidation.ValidateAsync(validator, body);
                if (invalid is not null)
                {
                    return invalid;
                }

                return Results.Ok(await service.UpdateSectionAsync(id, body));
            }
        );

        group.MapDelete(
            "/{id:int}",
            async (int id, ISectionService service) =>
            {
                await service.DeleteSectionAsync(id);
                return Results.NoContent();
            }
        );
    }
}
