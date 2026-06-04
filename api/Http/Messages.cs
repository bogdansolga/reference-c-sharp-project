namespace Api.Http;

/// <summary>User-facing messages. Mirrors the TS `Messages` (lib/core/i18n/messages).</summary>
public static class Messages
{
    public const string InternalServerError = "Internal Server Error";
    public const string Unauthorized = "Unauthorized";
    public const string Forbidden = "Forbidden: Admin access required";
    public const string NotFound = "Not found";
    public const string ValidationFailed = "Validation failed";

    public const string ProductNotFound = "Product not found";
    public const string SectionNotFound = "Section not found";
}
