require "test_helper"

class SearchApiPresentersTest < ActiveSupport::TestCase
  test "SearchApiPresenters.present_all_government_content includes publications, consultations, news articles, speeches, case studies" do
    edition_types = [Publication, Consultation, NewsArticle, Speech, CaseStudy]
    edition_types.each { |t| t.stubs(:search_index).returns([t.name.to_sym]) }
    search_content = SearchApiPresenters.present_all_government_content
    edition_types.each { |t| assert search_content.include?(t.name.to_sym) }
  end

  test "SearchApiPresenters.present_all_government_content excludes DetailedGuide" do
    DetailedGuide.stubs(search_index: ["a detailed guide"])
    assert_not SearchApiPresenters.present_all_government_content.include?("a detailed guide")
  end

  test "SearchApiPresenters.present_all_government_content includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert SearchApiPresenters.present_all_government_content.include?(:organisations)
  end

  test "SearchApiPresenters.present_all_detailed_content includes guidance" do
    DetailedGuide.stubs(:search_index).returns([:guidance])
    assert SearchApiPresenters.present_all_detailed_content.include?(:guidance)
  end
end
