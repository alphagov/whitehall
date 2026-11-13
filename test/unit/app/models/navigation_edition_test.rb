require "test_helper"

class NavigationEditionTest < ActiveSupport::TestCase
  test "belongs to navigation" do
    navigation_edition = NavigationEdition.new

    assert_respond_to navigation_edition, :navigation
    assert_instance_of Navigation, navigation_edition.navigation = Navigation.new
  end

  test "belongs to edition" do
    navigation_edition = NavigationEdition.new

    assert_respond_to navigation_edition, :edition
    assert_instance_of Edition, navigation_edition.edition = Edition.new
  end

  test "an edition can only have one navigation edition" do
    edition = create(:draft_standard_edition)
    NavigationEdition.create!(navigation: Navigation.create!(content_id: SecureRandom.uuid), edition:)

    assert_raises ActiveRecord::RecordNotUnique do
      NavigationEdition.create!(navigation: Navigation.create!(content_id: SecureRandom.uuid), edition:)
    end
  end
end
