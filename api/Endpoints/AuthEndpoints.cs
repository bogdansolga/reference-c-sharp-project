using Api.Auth;
using Api.Dtos;

namespace Api.Endpoints;

/// <summary>HTTP layer for auth. Mirrors the TS `/api/auth/login` and `/api/auth/logout` routes.</summary>
public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth");

        group.MapPost(
            "/login",
            (LoginRequest body, HttpContext ctx) =>
            {
                if (string.IsNullOrEmpty(body.Username) || string.IsNullOrEmpty(body.Password))
                {
                    return Results.BadRequest(new { error = "Username and password required" });
                }

                var user = SessionAuth.Login(ctx, body.Username, body.Password);
                if (user is null)
                {
                    return Results.Json(new { error = "Invalid credentials" }, statusCode: StatusCodes.Status401Unauthorized);
                }

                return Results.Ok(new { user = new UserResponse(user.Id, user.Username, user.Role) });
            }
        );

        group.MapPost(
            "/logout",
            (HttpContext ctx) =>
            {
                SessionAuth.Logout(ctx);
                return Results.Ok(new { success = true });
            }
        );
    }
}
