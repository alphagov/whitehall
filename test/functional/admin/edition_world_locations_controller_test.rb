require 'test_helper'

class Admin::EditionWorldLocationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'should allow featuring of the edition world location' do
    edition_world_location = create(:edition_world_location, featured: false)
    login_as :departmental_editor
    post :update, id: edition_world_location, edition_world_location: {featured: true}
    assert edition_world_location.reload.featured?
  end

  test 'should allow unfeaturing of the edition world location' do
    edition_world_location = create(:edition_world_location, featured: true)
    login_as :departmental_editor
    post :update, id: edition_world_location, edition_world_location: {featured: false}
    refute edition_world_location.reload.featured?
  end

  test "should redirect back to the world location's admin edit page" do
    world_location = create(:world_location)
    edition_world_location = create(:edition_world_location, world_location: world_location)
    login_as :departmental_editor
    post :update, id: edition_world_location, edition_world_location: {}
    assert_redirected_to edit_admin_world_location_path(world_location)
  end
end