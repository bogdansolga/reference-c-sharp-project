namespace Api.Domain;

/// <summary>A product section/category. Mirrors the TS `sections` table.</summary>
public class Section
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<Product> Products { get; set; } = new List<Product>();
}
