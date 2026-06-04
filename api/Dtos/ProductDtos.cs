namespace Api.Dtos;

/// <summary>Mirrors TS `CreateProductDto` (createProductSchema).</summary>
public record CreateProductDto(string Name, double Price, int SectionId);

/// <summary>Mirrors TS `UpdateProductDto` (createProductSchema.partial()). Nullable = "omitted".</summary>
public record UpdateProductDto(string? Name, double? Price, int? SectionId);

/// <summary>Mirrors TS `ProductResponse`.</summary>
public record ProductResponse(int Id, string Name, double Price, int SectionId);
