require "test_helper"

class WorldwideOrganisationsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper

  should_be_a_public_facing_controller

  test "shows worldwide organisation information" do
    organisation = create(:worldwide_organisation)
    get :show, id: organisation.id
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  view_test "shows links to associated world locations" do
    location_1 = create(:world_location)
    location_2 = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [location_1, location_2])

    get :show, id: organisation.id

    assert_select "a[href='#{world_location_path(location_1)}']"
    assert_select "a[href='#{world_location_path(location_2)}']"
  end

  test "show redirects to the api worldwide organisation endpoint when json is requested" do
    organisation = create(:worldwide_organisation)
    get :show, id: organisation.id, format: :json
    assert_redirected_to api_worldwide_organisation_path(organisation, format: :json)
  end

  view_test "showing an organisation without a list of contacts doesn't try to create one" do
    # needs to be a view_test so the entire view is rendered
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.main_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :show, id: worldwide_organisation

    worldwide_organisation.reload
    refute worldwide_organisation.has_home_page_offices_list?
  end

end
