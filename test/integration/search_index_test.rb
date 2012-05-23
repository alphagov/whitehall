require "test_helper"

class SearchIndexTest < ActiveSupport::TestCase
  test "Whitehall.search_index includes documents" do
    Edition.stubs(:search_index).returns([:documents])
    assert Whitehall.search_index.include?(:documents)
  end

  test "Whitehall.search_index includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert Whitehall.search_index.include?(:organisations)
  end

  test "Whitehall.search_index includes ministerial roles" do
    MinisterialRole.stubs(:search_index).returns([:ministerial_roles])
    assert Whitehall.search_index.include?(:ministerial_roles)
  end

  test "Whitehall.search_index includes supporting pages" do
    MinisterialRole.stubs(:search_index).returns([:supporting_pages])
    assert Whitehall.search_index.include?(:supporting_pages)
  end
end
