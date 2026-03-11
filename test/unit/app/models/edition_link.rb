require "test_helper"

class EditionLinkTest < ActiveSupport::TestCase
  test "should be invalid if linking to itself" do
    @standard_edition = create(:standard_edition)
    edition_link = EditionLink.new(edition: @standard_edition, document: @standard_edition.document)
    assert_not edition_link.valid?
  end
end
