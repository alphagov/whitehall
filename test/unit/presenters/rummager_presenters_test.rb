require "test_helper"

class RummagerPresentersTest < ActiveSupport::TestCase
  test "RummagerPresenters.present_all_government_content includes publications, consultations, news articles, speeches, case studies" do
    edition_types = [Publication, Consultation, NewsArticle, Speech, CaseStudy]
    edition_types.each { |t| t.stubs(:search_index).returns([t.name.to_sym]) }
    search_content = RummagerPresenters.present_all_government_content
    edition_types.each { |t| assert search_content.include?(t.name.to_sym) }
  end

  test "RummagerPresenters.present_all_government_content excludes DetailedGuide" do
    DetailedGuide.stubs(search_index: ['a detailed guide'])
    refute RummagerPresenters.present_all_government_content.include?('a detailed guide')
  end

  test "RummagerPresenters.present_all_government_content includes WorldLocationNewsArticles" do
    WorldLocationNewsArticle.stubs(search_index: %w[world_location_news_articles_index])
    assert RummagerPresenters.present_all_government_content.include?('world_location_news_articles_index')
  end

  test "RummagerPresenters.present_all_government_content includes WorldLocations" do
    WorldLocation.stubs(search_index: %w[world_locations_index])
    assert RummagerPresenters.present_all_government_content.include?('world_locations_index')
  end

  test "RummagerPresenters.present_all_government_content includes WorldwideOrganisations" do
    WorldwideOrganisation.stubs(search_index: %w[worldwide_organisations_index])
    assert RummagerPresenters.present_all_government_content.include?('worldwide_organisations_index')
  end

  test "RummagerPresenters.present_all_government_content includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert RummagerPresenters.present_all_government_content.include?(:organisations)
  end

  test "RummagerPresenters.present_all_government_content includes ministerial roles" do
    MinisterialRole.stubs(:search_index).returns([:ministerial_roles])
    assert RummagerPresenters.present_all_government_content.include?(:ministerial_roles)
  end

  test "RummagerPresenters.present_all_detailed_content includes guidance" do
    DetailedGuide.stubs(:search_index).returns([:guidance])
    assert RummagerPresenters.present_all_detailed_content.include?(:guidance)
  end
end
