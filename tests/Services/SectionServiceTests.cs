using Api.Domain;
using Api.Domain.Errors;
using Api.Dtos;
using Api.Repositories;
using Api.Services;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Tests.Services;

// Mirrors the Vitest section-service.test.ts (repository mocked).
public class SectionServiceTests
{
    private readonly ISectionRepository _repo = Substitute.For<ISectionRepository>();
    private readonly SectionService _service;

    public SectionServiceTests() => _service = new SectionService(_repo);

    [Fact]
    public async Task GetAllSections_returns_mapped_sections()
    {
        _repo.FindAllAsync().Returns([new Section { Id = 1, Name = "Electronics" }]);

        var result = await _service.GetAllSectionsAsync();

        result.Should().ContainSingle().Which.Should().BeEquivalentTo(new SectionResponse(1, "Electronics"));
    }

    [Fact]
    public async Task GetSectionById_returns_section_when_found()
    {
        _repo.FindByIdAsync(1).Returns(new Section { Id = 1, Name = "Electronics" });

        var result = await _service.GetSectionByIdAsync(1);

        result.Should().BeEquivalentTo(new SectionResponse(1, "Electronics"));
    }

    [Fact]
    public async Task GetSectionById_throws_when_not_found()
    {
        _repo.FindByIdAsync(1).Returns((Section?)null);

        var act = () => _service.GetSectionByIdAsync(1);

        await act.Should().ThrowAsync<NotFoundException>().WithMessage("Section not found");
    }

    [Fact]
    public async Task CreateSection_returns_created_section()
    {
        _repo.CreateAsync(Arg.Any<Section>()).Returns(new Section { Id = 1, Name = "New Section" });

        var result = await _service.CreateSectionAsync(new CreateSectionDto("New Section"));

        result.Should().BeEquivalentTo(new SectionResponse(1, "New Section"));
    }

    [Fact]
    public async Task UpdateSection_returns_updated_when_found()
    {
        _repo.FindByIdAsync(1).Returns(new Section { Id = 1, Name = "Old" });
        _repo.UpdateAsync(1, "Updated").Returns(new Section { Id = 1, Name = "Updated" });

        var result = await _service.UpdateSectionAsync(1, new UpdateSectionDto("Updated"));

        result.Should().BeEquivalentTo(new SectionResponse(1, "Updated"));
    }

    [Fact]
    public async Task UpdateSection_throws_when_not_found()
    {
        _repo.FindByIdAsync(1).Returns((Section?)null);

        var act = () => _service.UpdateSectionAsync(1, new UpdateSectionDto("Updated"));

        await act.Should().ThrowAsync<NotFoundException>().WithMessage("Section not found");
    }

    [Fact]
    public async Task DeleteSection_succeeds_when_found()
    {
        _repo.FindByIdAsync(1).Returns(new Section { Id = 1, Name = "Electronics" });

        var act = () => _service.DeleteSectionAsync(1);

        await act.Should().NotThrowAsync();
        await _repo.Received(1).DeleteAsync(1);
    }

    [Fact]
    public async Task DeleteSection_throws_when_not_found()
    {
        _repo.FindByIdAsync(1).Returns((Section?)null);

        var act = () => _service.DeleteSectionAsync(1);

        await act.Should().ThrowAsync<NotFoundException>().WithMessage("Section not found");
    }
}
