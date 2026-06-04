using Api.Dtos;
using Api.Http;
using Api.Services;
using FluentValidation;

namespace Api.Endpoints;

/// <summary>
/// HTTP layer for products. Mirrors the TS `/api/v1/product` routes.
/// Calls services only — never repositories (enforced by the architecture check).
/// </summary>
public static class ProductEndpoints
{
    public static void MapProductEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/v1/product");

        group.MapGet("", async (IProductService service) => Results.Ok(await service.GetAllProductsAsync()));

        group.MapGet(
            "/{id:int}",
            async (int id, IProductService service) => Results.Ok(await service.GetProductByIdAsync(id))
        );

        group.MapPost(
            "",
            async (CreateProductDto body, IValidator<CreateProductDto> validator, IProductService service) =>
            {
                var invalid = await RequestValidation.ValidateAsync(validator, body);
                if (invalid is not null)
                {
                    return invalid;
                }

                var product = await service.CreateProductAsync(body);
                return Results.Created($"/api/v1/product/{product.Id}", product);
            }
        );

        group.MapPut(
            "/{id:int}",
            async (int id, UpdateProductDto body, IValidator<UpdateProductDto> validator, IProductService service) =>
            {
                var invalid = await RequestValidation.ValidateAsync(validator, body);
                if (invalid is not null)
                {
                    return invalid;
                }

                return Results.Ok(await service.UpdateProductAsync(id, body));
            }
        );

        group.MapDelete(
            "/{id:int}",
            async (int id, IProductService service) =>
            {
                await service.DeleteProductAsync(id);
                return Results.NoContent();
            }
        );
    }
}
