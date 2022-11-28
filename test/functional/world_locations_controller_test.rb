require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include FeedHelper

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

  test "index when asked for json should redirect to the api controller" do
    get :index, format: :json
    assert_redirected_to api_world_locations_path(format: :json)
  end
end
