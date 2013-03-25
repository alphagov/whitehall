require "test_helper"

class Admin::WorldLocationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should return active and inactive world locations in alphabetical order' do
    active = [
      create(:world_location, name: 'zzz', active: true),
      create(:world_location, name: 'aaa', active: true)
    ]
    inactive = [
      create(:world_location, name: 'zzz', active: false),
      create(:world_location, name: 'aaa', active: false)
    ]

    get :index

    assert_equal active.sort_by(&:name), assigns(:active_world_locations)
    assert_equal inactive.sort_by(&:name), assigns(:inactive_world_locations)
  end

  view_test 'should allow modification of existing world location data' do
    world_location = create(:world_location)

    get :edit, id: world_location

    assert_template 'world_locations/edit'
    assert_select "input[name='world_location[title]']"
    assert_select "textarea[name='world_location[mission_statement]']"
  end

  test 'updating should modify the world location' do
    world_location = create(:world_location)

    put :update, id: world_location, world_location: { mission_statement: 'country-mission-statement' }

    world_location.reload
    assert_equal 'country-mission-statement', world_location.mission_statement
  end

  test 'after updating redirects to world location show page' do
    world_location = create(:world_location)

    put :update, id: world_location, world_location: { mission_statement: 'country-mission-statement' }

    assert_redirected_to [:admin, world_location]
  end

  view_test "should display fields for new mainstream links" do
    world_location = create(:world_location)

    get :edit, id: world_location

    assert_select "input[type=text][name='world_location[mainstream_links_attributes][0][url]']"
    assert_select "input[type=text][name='world_location[mainstream_links_attributes][0][title]']"
  end

  test "updating should be able to create a new mainstream links" do
    world_location = create(:world_location)

    post :update, id: world_location, world_location: {
      mainstream_links_attributes: {"0" =>{
        url: "http://www.gov.uk/mainstream/something",
        title: "Something on mainstream"
      }}
    }

    assert world_location = WorldLocation.last
    assert mainstream_link = world_location.mainstream_links.last
    assert_equal "http://www.gov.uk/mainstream/something", mainstream_link.url
    assert_equal "Something on mainstream", mainstream_link.title
  end

  test "updating should destroy existing mainstream links if all its field are blank" do
    world_location = create(:world_location)
    link = create(:world_location_mainstream_link, world_location: world_location)

    put :update, id: world_location, world_location: {
      mainstream_links_attributes: {"0" =>{
          id: link.mainstream_link.id,
          url: "",
          title: ""
      }}
    }

    assert_equal 0, world_location.mainstream_links.length
  end

  test "get features with locale should find feature list if present" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :fr)

    put :features, id: world_location, locale: :fr

    assert_equal feature_list, assigns[:feature_list]
  end

  test "get features should create feature list if not present" do
    world_location = create(:world_location)

    put :features, id: world_location, locale: :fr

    world_location.reload

    assert_equal ["fr"], world_location.feature_lists.map(&:locale)
  end
end
