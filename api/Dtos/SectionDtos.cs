namespace Api.Dtos;

/// <summary>Mirrors TS `CreateSectionDto`.</summary>
public record CreateSectionDto(string Name);

/// <summary>Mirrors TS `UpdateSectionDto`. Nullable Name = "omitted".</summary>
public record UpdateSectionDto(string? Name);

/// <summary>Mirrors TS `SectionResponse`.</summary>
public record SectionResponse(int Id, string Name);
