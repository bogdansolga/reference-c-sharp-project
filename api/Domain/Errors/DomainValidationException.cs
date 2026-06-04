namespace Api.Domain.Errors;

/// <summary>
/// Domain error → HTTP 400. Mirrors the TS `ValidationError` (mapped by name in the
/// centralized error handler). Distinct from FluentValidation's request validation,
/// which is handled at the endpoint boundary.
/// </summary>
public sealed class DomainValidationException(string message) : Exception(message);
