require "test_helper"

class NavigationItemTest < ActiveSupport::TestCase
  test "belongs to navigation_edition" do
    navigation_item = NavigationItem.new

    assert_respond_to navigation_item, :navigation_edition
    assert_instance_of NavigationEdition, navigation_item.navigation_edition = NavigationEdition.new
  end

  test "belongs to child_document" do
    navigation_item = NavigationItem.new

    assert_respond_to navigation_item, :child_document
    assert_instance_of Document, navigation_item.child_document = Document.new
  end

  test "#child_edition returns the latest edition of the child document" do
    published_edition = create(:published_standard_edition)
    draft_edition = published_edition.create_draft(create(:writer))
    navigation_item = create(:navigation_item, child_document: published_edition.document)

    assert_equal draft_edition, navigation_item.child_edition
  end
end
