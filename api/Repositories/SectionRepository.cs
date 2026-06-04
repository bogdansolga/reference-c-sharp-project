using Api.Data;
using Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace Api.Repositories;

/// <summary>
/// EF Core data access only — no HTTP concerns (enforced by the deep-architecture check).
/// Mirrors the TS `sectionRepository`.
/// </summary>
public class SectionRepository(AppDbContext db) : ISectionRepository
{
    public async Task<List<Section>> FindAllAsync() => await db.Sections.AsNoTracking().ToListAsync();

    public async Task<Section?> FindByIdAsync(int id) =>
        await db.Sections.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);

    public async Task<Section> CreateAsync(Section section)
    {
        db.Sections.Add(section);
        await db.SaveChangesAsync();
        return section;
    }

    public async Task<Section?> UpdateAsync(int id, string? name)
    {
        var section = await db.Sections.FirstOrDefaultAsync(s => s.Id == id);
        if (section is null)
        {
            return null;
        }

        if (name is not null)
        {
            section.Name = name;
        }

        await db.SaveChangesAsync();
        return section;
    }

    public async Task DeleteAsync(int id)
    {
        var section = await db.Sections.FirstOrDefaultAsync(s => s.Id == id);
        if (section is not null)
        {
            db.Sections.Remove(section);
            await db.SaveChangesAsync();
        }
    }
}
