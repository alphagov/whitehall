require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  def setup
    @rummager = stub
  end

  def assert_featured_editions(editions)
    assert_equal editions, assigns(:feature_list).current_featured.map(&:edition)
  end

  view_test "index should display a list of world locations" do
    bat = create(:world_location, name: "British Antarctic Territory")
    png = create(:world_location, name: "Papua New Guinea")

    get :index

    assert_select ".world-locations" do
      assert_select_object bat
      assert_select_object png
    end
  end
end
