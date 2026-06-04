using System.Reflection;
using Api.Data;
using Api.Endpoints;
using Api.Http;
using Api.Repositories;
using Api.Services;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Bind to :5099 by default (the web/ tier proxies /api/* here). Mirrors the TS dev port split.
if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("ASPNETCORE_URLS")))
{
    builder.WebHost.UseUrls("http://localhost:5099");
}

// Database — SQLite, path from DATABASE_URL (mirrors the TS default "sqlite.db").
var databasePath = Environment.GetEnvironmentVariable("DATABASE_URL") ?? "sqlite.db";
builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlite($"Data Source={databasePath}"));

// Layered DI: services depend on repositories (the architecture the checks enforce).
builder.Services.AddScoped<ISectionRepository, SectionRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ISectionService, SectionService>();
builder.Services.AddScoped<IProductService, ProductService>();

// Request validation (FluentValidation) — validators live in Api.Validation, never inline.
builder.Services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

// Allow the Next.js dev server to call the API directly (with cookies) during development.
const string DevCorsPolicy = "DevCors";
builder.Services.AddCors(options =>
    options.AddPolicy(
        DevCorsPolicy,
        policy => policy.WithOrigins("http://localhost:3000").AllowAnyHeader().AllowAnyMethod().AllowCredentials()
    )
);

var app = builder.Build();

// Centralized error handling (mirrors the TS handleError) — first in the pipeline.
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors(DevCorsPolicy);

// Create tables + seed on startup (mirrors the TS instrumentation seed; no migrations).
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.EnsureCreatedAsync();
    await Seeder.SeedAsync(db);
}

app.MapSectionEndpoints();
app.MapProductEndpoints();
app.MapAuthEndpoints();

await app.RunAsync();

// Exposed for WebApplicationFactory<Program> in the integration tests.
public partial class Program;
