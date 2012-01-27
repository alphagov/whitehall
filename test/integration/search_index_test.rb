require "test_helper"

class SearchIndexTest < ActiveSupport::TestCase
  test "Whitehall.search_index includes documents" do
    Document.stubs(:search_index_published).returns([:documents])
    assert Whitehall.search_index.include?(:documents)
  end

  test "Whitehall.search_index includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert Whitehall.search_index.include?(:organisations)
  end
end
