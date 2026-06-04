using FluentValidation;

namespace Api.Http;

/// <summary>
/// Endpoint-boundary request validation. Mirrors the TS `schema.safeParse` + 400 response
/// shape: { error: "Validation failed", details: { field: [messages] } }.
/// </summary>
public static class RequestValidation
{
    public static async Task<IResult?> ValidateAsync<T>(IValidator<T> validator, T dto)
    {
        var result = await validator.ValidateAsync(dto);
        if (result.IsValid)
        {
            return null;
        }

        var details = result
            .Errors.GroupBy(e => e.PropertyName)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());
        return Results.BadRequest(new { error = Messages.ValidationFailed, details });
    }
}
