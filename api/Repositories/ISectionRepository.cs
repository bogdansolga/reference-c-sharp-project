using Api.Domain;

namespace Api.Repositories;

/// <summary>Data access for sections. Mirrors the TS `sectionRepository`.</summary>
public interface ISectionRepository
{
    Task<List<Section>> FindAllAsync();
    Task<Section?> FindByIdAsync(int id);
    Task<Section> CreateAsync(Section section);
    Task<Section?> UpdateAsync(int id, string? name);
    Task DeleteAsync(int id);
}
