require "test_helper"

class FeaturedLinkTest < ActiveSupport::TestCase
  test "should not be valid without a url" do
    link = build(:featured_link, url: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:featured_link, title: nil)
    refute link.valid?
  end

  test "should not be valid with a url that doesn't start with http" do
    link = build(:featured_link, url: "not a link")
    refute link.valid?
  end
end
