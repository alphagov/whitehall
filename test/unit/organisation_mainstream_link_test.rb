require "test_helper"

class OrganisationMainstreamLinkTest < ActiveSupport::TestCase
  test "should not be valid without a url" do
    link = build(:organisation_mainstream_link, url: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:organisation_mainstream_link, title: nil)
    refute link.valid?
  end

  test "should not be valid with a url that doesn't start with http" do
    link = build(:organisation_mainstream_link, url: "not a link")
    refute link.valid?
  end
end
