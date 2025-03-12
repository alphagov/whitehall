require "test_helper"

class SearchApiPresentersTest < ActiveSupport::TestCase
  test "SearchApiPresenters.present_all_government_content includes organisations" do
    Organisation.stubs(:search_index).returns([:organisations])
    assert SearchApiPresenters.present_all_government_content.include?(:organisations)
  end
end
