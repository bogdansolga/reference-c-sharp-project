using System.Text.Json;

namespace Api.Auth;

/// <summary>The user record stored in the session cookie. Mirrors the TS session payload.</summary>
public record SessionUser(string Id, string Username, string Role);

/// <summary>
/// Cookie-based session auth. Mirrors the TS `lib/auth` (login/logout/getSession).
/// httpOnly cookie "session" stores {id, username, role} as JSON.
/// Test users: user/user (USER), admin/admin (ADMIN).
/// </summary>
public static class SessionAuth
{
    private const string SessionCookie = "session";
    private static readonly TimeSpan SessionMaxAge = TimeSpan.FromDays(1);
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private static readonly (string Id, string Username, string Password, string Role)[] Users =
    [
        ("1", "user", "user", "USER"),
        ("2", "admin", "admin", "ADMIN"),
    ];

    /// <summary>Validates credentials and sets the session cookie. Returns null on failure.</summary>
    public static SessionUser? Login(HttpContext ctx, string username, string password)
    {
        var match = Users.FirstOrDefault(u => u.Username == username && u.Password == password);
        if (match.Id is null)
        {
            return null;
        }

        var user = new SessionUser(match.Id, match.Username, match.Role);
        ctx.Response.Cookies.Append(
            SessionCookie,
            JsonSerializer.Serialize(user, JsonOptions),
            new CookieOptions
            {
                HttpOnly = true,
                Secure = !ctx.Request.Host.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase),
                SameSite = SameSiteMode.Lax,
                MaxAge = SessionMaxAge,
                Path = "/",
            }
        );
        return user;
    }

    /// <summary>Clears the session cookie.</summary>
    public static void Logout(HttpContext ctx) => ctx.Response.Cookies.Delete(SessionCookie);

    /// <summary>Reads and parses the session cookie. Returns null when absent/invalid.</summary>
    public static SessionUser? GetSession(HttpContext ctx)
    {
        var raw = ctx.Request.Cookies[SessionCookie];
        if (string.IsNullOrEmpty(raw))
        {
            return null;
        }

        try
        {
            return JsonSerializer.Deserialize<SessionUser>(raw, JsonOptions);
        }
        catch (JsonException)
        {
            return null;
        }
    }
}
