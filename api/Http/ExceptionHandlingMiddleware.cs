using Api.Domain.Errors;

namespace Api.Http;

/// <summary>
/// Centralized error handler. Mirrors the TS `handleError`: domain error type → HTTP status,
/// everything else logged and returned as 500. Keeps endpoints free of try/catch.
/// </summary>
public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (NotFoundException ex)
        {
            await WriteError(context, StatusCodes.Status404NotFound, ex.Message);
        }
        catch (DomainValidationException ex)
        {
            await WriteError(context, StatusCodes.Status400BadRequest, ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unexpected error");
            await WriteError(context, StatusCodes.Status500InternalServerError, Messages.InternalServerError);
        }
    }

    private static Task WriteError(HttpContext context, int status, string message)
    {
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/json";
        return context.Response.WriteAsJsonAsync(new { error = message });
    }
}
