require "test_helper"

class SearchIndexTest < ActiveSupport::TestCase
  test "Whitehall.government_search_index includes publications, consultations, news articles, speeches, case studies" do
    edition_types = [Publication, Consultation, NewsArticle, Speech, CaseStudy]
    edition_types.each {|t| t.stubs(:search_index).returns([t.name.to_sym])}
    search_index = Whitehall.government_search_index
    edition_types.each {|t| assert search_index.include?(t.name.to_sym)}
  end

  test "Whitehall.government_search_index excludes DetailedGuide" do
    DetailedGuide.stubs(search_index: ['a detailed guide'])
    refute Whitehall.government_search_index.include?('a detailed guide')
  end

  test "Whitehall.government_search_index includes WorldLocationNewsArticles" do
    WorldLocationNewsArticle.stubs(search_index: ['world_location_news_articles_index'])
    assert Whitehall.government_search_index.include?('world_location_news_articles_index')
  end

  test "Whitehall.government_search_index includes WorldLocations" do
    WorldLocation.stubs(search_index: ['world_locations_index'])
    assert Whitehall.government_search_index.include?('world_locations_index')
  end

  test "Whitehall.government_search_index includes WorldwideOrganisations" do
    WorldwideOrganisation.stubs(search_index: ['worldwide_organisations_index'])
    assert Whitehall.government_search_index.include?('worldwide_organisations_index')
  end

  test "Whitehall.government_search_index includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert Whitehall.government_search_index.include?(:organisations)
  end

  test "Whitehall.government_search_index includes ministerial roles" do
    MinisterialRole.stubs(:search_index).returns([:ministerial_roles])
    assert Whitehall.government_search_index.include?(:ministerial_roles)
  end

  test "Whitehall.detailed_guidance_search_index includes guidance" do
    DetailedGuide.stubs(:search_index).returns([:guidance])
    assert Whitehall.detailed_guidance_search_index.include?(:guidance)
  end
end
