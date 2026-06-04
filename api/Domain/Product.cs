namespace Api.Domain;

/// <summary>A product belonging to a section. Mirrors the TS `products` table.</summary>
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public double Price { get; set; }
    public int SectionId { get; set; }

    public Section? Section { get; set; }
}
