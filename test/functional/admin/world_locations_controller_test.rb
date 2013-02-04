require "test_helper"

class Admin::WorldLocationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should allow modification of existing world location data' do
    world_location = create(:world_location)

    get :edit, id: world_location

    assert_template 'world_locations/edit'
    assert_select "textarea[name='world_location[description]']"
    assert_select '#govspeak_help'
  end

  test 'updating should modify the world location' do
    world_location = create(:world_location)

    put :update, id: world_location, world_location: { description: 'country-description' }

    world_location.reload
    assert_equal 'country-description', world_location.description
  end
end