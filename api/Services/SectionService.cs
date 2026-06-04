using Api.Domain;
using Api.Domain.Errors;
using Api.Dtos;
using Api.Http;
using Api.Repositories;

namespace Api.Services;

/// <summary>
/// Mirrors the TS `sectionService`. Throws domain errors (never a generic Exception —
/// enforced by the deep-architecture check).
/// </summary>
public class SectionService(ISectionRepository sections) : ISectionService
{
    public async Task<List<SectionResponse>> GetAllSectionsAsync()
    {
        var all = await sections.FindAllAsync();
        return all.Select(s => new SectionResponse(s.Id, s.Name)).ToList();
    }

    public async Task<SectionResponse> GetSectionByIdAsync(int id)
    {
        var section = await sections.FindByIdAsync(id) ?? throw new NotFoundException(Messages.SectionNotFound);
        return new SectionResponse(section.Id, section.Name);
    }

    public async Task<SectionResponse> CreateSectionAsync(CreateSectionDto data)
    {
        var created = await sections.CreateAsync(new Section { Name = data.Name });
        return new SectionResponse(created.Id, created.Name);
    }

    public async Task<SectionResponse> UpdateSectionAsync(int id, UpdateSectionDto data)
    {
        var existing = await sections.FindByIdAsync(id) ?? throw new NotFoundException(Messages.SectionNotFound);
        var updated =
            await sections.UpdateAsync(existing.Id, data.Name) ?? throw new NotFoundException(Messages.SectionNotFound);
        return new SectionResponse(updated.Id, updated.Name);
    }

    public async Task DeleteSectionAsync(int id)
    {
        _ = await sections.FindByIdAsync(id) ?? throw new NotFoundException(Messages.SectionNotFound);
        await sections.DeleteAsync(id);
    }
}
