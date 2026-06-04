using Api.Auth;

namespace Api.Http;

/// <summary>
/// Path-based authorization. Faithful port of the TS Next.js `proxy.ts`:
///   - /api/auth/*  → open
///   - /api/v1/*    → requires a valid session (401), writes require ADMIN (403)
///   - everything else (e.g. /api/chat lives in the web tier) → open
/// </summary>
public class AuthorizationMiddleware(RequestDelegate next)
{
    private static readonly string[] WriteMethods = ["POST", "PUT", "DELETE"];

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value ?? string.Empty;

        if (path.StartsWith("/api/auth", StringComparison.OrdinalIgnoreCase))
        {
            await next(context);
            return;
        }

        if (path.StartsWith("/api/v1", StringComparison.OrdinalIgnoreCase))
        {
            var session = SessionAuth.GetSession(context);
            if (session is null)
            {
                await Write(context, StatusCodes.Status401Unauthorized, Messages.Unauthorized);
                return;
            }

            if (WriteMethods.Contains(context.Request.Method) && session.Role != "ADMIN")
            {
                await Write(context, StatusCodes.Status403Forbidden, Messages.Forbidden);
                return;
            }
        }

        await next(context);
    }

    private static Task Write(HttpContext context, int status, string message)
    {
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/json";
        return context.Response.WriteAsJsonAsync(new { error = message });
    }
}
