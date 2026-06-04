namespace Api.Dtos;

/// <summary>Login request body. Mirrors the TS login route payload.</summary>
public record LoginRequest(string? Username, string? Password);

/// <summary>Authenticated user view returned to the client (no password).</summary>
public record UserResponse(string Id, string Username, string Role);
