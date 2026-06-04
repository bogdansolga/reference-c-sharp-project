using Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace Api.Data;

/// <summary>
/// EF Core context over SQLite. Mirrors the TS Drizzle schema (table/column names kept
/// identical: `sections`, `products`, `section_id`).
/// </summary>
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Section> Sections => Set<Section>();
    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Section>(entity =>
        {
            entity.ToTable("sections");
            entity.HasKey(s => s.Id);
            entity.Property(s => s.Id).HasColumnName("id");
            entity.Property(s => s.Name).HasColumnName("name").IsRequired();
            entity.HasIndex(s => s.Name).IsUnique();
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.ToTable("products");
            entity.HasKey(p => p.Id);
            entity.Property(p => p.Id).HasColumnName("id");
            entity.Property(p => p.Name).HasColumnName("name").IsRequired();
            entity.Property(p => p.Price).HasColumnName("price").IsRequired();
            entity.Property(p => p.SectionId).HasColumnName("section_id").IsRequired();
            entity.HasIndex(p => p.Name).IsUnique();
            entity
                .HasOne(p => p.Section)
                .WithMany(s => s.Products)
                .HasForeignKey(p => p.SectionId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
