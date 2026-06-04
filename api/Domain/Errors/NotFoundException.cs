namespace Api.Domain.Errors;

/// <summary>
/// Domain error → HTTP 404. Mirrors the TS `NotFoundError` (mapped by name in the
/// centralized error handler). Services throw this instead of a generic exception.
/// </summary>
public sealed class NotFoundException(string message) : Exception(message);
