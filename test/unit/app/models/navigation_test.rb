require "test_helper"

class NavigationTest < ActiveSupport::TestCase
  test "has many navigation_editions" do
    navigation = Navigation.new
    assert_respond_to navigation, :navigation_editions
  end
end
