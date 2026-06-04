using Api.Dtos;

namespace Api.Services;

/// <summary>Business logic for sections. Mirrors the TS `sectionService`.</summary>
public interface ISectionService
{
    Task<List<SectionResponse>> GetAllSectionsAsync();
    Task<SectionResponse> GetSectionByIdAsync(int id);
    Task<SectionResponse> CreateSectionAsync(CreateSectionDto data);
    Task<SectionResponse> UpdateSectionAsync(int id, UpdateSectionDto data);
    Task DeleteSectionAsync(int id);
}
