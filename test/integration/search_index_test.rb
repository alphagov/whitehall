require "test_helper"

class SearchIndexTest < ActiveSupport::TestCase
  test "Whitehall.government_search_index includes policies, publications, announcements, international priorities, case studies" do
    edition_types = [Policy, Publicationesque, Announcement, InternationalPriority, CaseStudy]
    edition_types.each {|t| t.stubs(:search_index).returns([t.name.to_sym])}
    search_index = Whitehall.government_search_index
    edition_types.each {|t| assert search_index.include?(t.name.to_sym)}
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

  test "Whitehall.specialist_search_index includes guidance" do
    SpecialistGuide.stubs(:search_index).returns([:guidance])
    assert Whitehall.specialist_search_index.include?(:guidance)
  end
end
