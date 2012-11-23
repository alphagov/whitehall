require "test_helper"

class OrganisationMainstreamLinkTest < ActiveSupport::TestCase
  test "should not be valid without a slug" do
    link = build(:organisation_mainstream_link, slug: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:organisation_mainstream_link, title: nil)
    refute link.valid?
  end
end
