require "test_helper"

class HomePageListItemTest < ActiveSupport::TestCase
  test "is invalid without an item" do
    item = build(:home_page_list_item, item: nil)
    assert_not item.valid?
  end

  test "is invalid without a list" do
    item = build(:home_page_list_item, home_page_list: nil)
    assert_not item.valid?
  end
end
