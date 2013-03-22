require "test_helper"

class SearchIndexTest < ActiveSupport::TestCase
  test "Whitehall.government_search_index includes policies, publications, consultations, news articles, speeches, case studies" do
    edition_types = [Policy, Publication, Consultation, NewsArticle, Speech, CaseStudy]
    edition_types.each {|t| t.stubs(:search_index).returns([t.name.to_sym])}
    search_index = Whitehall.government_search_index
    edition_types.each {|t| assert search_index.include?(t.name.to_sym)}
  end

  test "Whitehall.government_search_index does not include WorldwidePriorities if the world_feature? is false" do
    Whitehall.stubs(:world_feature?).returns(false)
    WorldwidePriority.stubs(search_index: ['worldwide_priorities_index'])
    refute Whitehall.government_search_index.include?('worldwide_priorities_index')
  end

  test "Whitehall.government_search_index does include WorldwidePriorities if the world_feature? is true" do
    Whitehall.stubs(:world_feature?).returns(true)
    WorldwidePriority.stubs(search_index: ['worldwide_priorities_index'])
    assert Whitehall.government_search_index.include?('worldwide_priorities_index')
  end

  test "Whitehall.government_search_index does not include WorldLocationNewsArticles if the world_feature? is false" do
    Whitehall.stubs(:world_feature?).returns(false)
    WorldLocationNewsArticle.stubs(search_index: ['world_location_news_articles_index'])
    refute Whitehall.government_search_index.include?('world_location_news_articles_index')
  end

  test "Whitehall.government_search_index does include WorldLocationNewsArticles if the world_feature? is true" do
    Whitehall.stubs(:world_feature?).returns(true)
    WorldLocationNewsArticle.stubs(search_index: ['world_location_news_articles_index'])
    assert Whitehall.government_search_index.include?('world_location_news_articles_index')
  end

  test "Whitehall.government_search_index does not include WorldLocations if the world_feature? is false" do
    Whitehall.stubs(:world_feature?).returns(false)
    WorldLocation.stubs(search_index: ['world_locations_index'])
    refute Whitehall.government_search_index.include?('world_locations_index')
  end

  test "Whitehall.government_search_index does include WorldLocations if the world_feature? is true" do
    Whitehall.stubs(:world_feature?).returns(true)
    WorldLocation.stubs(search_index: ['world_locations_index'])
    assert Whitehall.government_search_index.include?('world_locations_index')
  end

  test "Whitehall.government_search_index does not include WorldwideOrganisations if the world_feature? is false" do
    Whitehall.stubs(:world_feature?).returns(false)
    WorldwideOrganisation.stubs(search_index: ['worldwide_organisations_index'])
    refute Whitehall.government_search_index.include?('worldwide_organisations_index')
  end

  test "Whitehall.government_search_index does include WorldwideOrganisations if the world_feature? is true" do
    Whitehall.stubs(:world_feature?).returns(true)
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

  test "Whitehall.government_search_index includes supporting pages" do
    MinisterialRole.stubs(:search_index).returns([:supporting_pages])
    assert Whitehall.government_search_index.include?(:supporting_pages)
  end

  test "Whitehall.detailed_guidance_search_index includes guidance" do
    DetailedGuide.stubs(:search_index).returns([:guidance])
    assert Whitehall.detailed_guidance_search_index.include?(:guidance)
  end
end
