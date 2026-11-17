require "test_helper"

class NavigationEditionTest < ActiveSupport::TestCase
  test "belongs to navigation" do
    navigation_edition = NavigationEdition.new

    assert_respond_to navigation_edition, :navigation
    assert_instance_of Navigation, navigation_edition.navigation = Navigation.new
  end

  test "belongs to StandardEdition" do
    navigation_edition = NavigationEdition.new

    assert_respond_to navigation_edition, :edition
    assert_instance_of StandardEdition, navigation_edition.edition = StandardEdition.new
  end

  test "an edition can only have one navigation edition" do
    edition = create(:draft_standard_edition)
    NavigationEdition.create!(navigation: Navigation.create!(content_id: SecureRandom.uuid), edition:)

    assert_raises ActiveRecord::RecordNotUnique do
      NavigationEdition.create!(navigation: Navigation.create!(content_id: SecureRandom.uuid), edition:)
    end
  end

  test "has navigation items" do
    navigation_edition = create(:navigation_edition)
    NavigationItem.create!(navigation_edition: navigation_edition, child_document: FactoryBot.create(:document))
    NavigationItem.create!(navigation_edition: navigation_edition, child_document: FactoryBot.create(:document))

    assert_respond_to navigation_edition, :navigation_items
    assert_equal 2, navigation_edition.navigation_items.count
  end

  test "destroys its navigation items when destroyed" do
    navigation_edition = create(:navigation_edition)
    create(:navigation_item, navigation_edition:)

    assert_difference -> { NavigationItem.count }, -1 do
      navigation_edition.destroy!
    end
  end
end
