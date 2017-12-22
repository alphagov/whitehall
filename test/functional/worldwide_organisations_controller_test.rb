require "test_helper"

class WorldwideOrganisationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "shows worldwide organisation information" do
    organisation = create(:worldwide_organisation)
    get :show, params: { id: organisation.id }
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  test "sets meta description" do
    organisation = create(:worldwide_organisation)
    create(:about_corporate_information_page, organisation: nil, worldwide_organisation: organisation, summary: 'my summary')

    get :show, params: { id: organisation.id }

    assert_equal 'my summary', assigns(:meta_description)
  end

  test "should populate slimmer organisations header with worldwide organisation and its sponsored organisations" do
    organisation = create(:worldwide_organisation, :translated, :with_sponsorships)
    sponsoring_organisation = organisation.sponsoring_organisations.first

    get :show, params: { id: organisation.id }

    expected_header_value = "<#{organisation.analytics_identifier}><#{sponsoring_organisation.analytics_identifier}>"
    assert_equal expected_header_value, response.headers["X-Slimmer-Organisations"]
  end

  test "should set slimmer worldwide locations header" do
    world_location = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [world_location])

    get :show, params: { id: organisation.id }

    assert_equal "<#{world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
  end

  view_test "shows links to associated world locations" do
    location_1 = create(:world_location)
    location_2 = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [location_1, location_2])

    get :show, params: { id: organisation.id }

    assert_select "a[href='#{world_location_path(location_1)}']"
    assert_select "a[href='#{world_location_path(location_2)}']"
  end

  test "show redirects to the api worldwide organisation endpoint when json is requested" do
    organisation = create(:worldwide_organisation)
    get :show, params: { id: organisation.id }, format: :json
    assert_redirected_to api_worldwide_organisation_path(organisation, format: :json)
  end

  view_test "showing an organisation without a list of contacts doesn't try to create one" do
    # needs to be a view_test so the entire view is rendered
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.main_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :show, params: { id: worldwide_organisation }

    worldwide_organisation.reload
    refute worldwide_organisation.has_home_page_offices_list?
  end

  view_test "showing a preview of draft content when requested and a user is logged in" do
    login_as :gds_editor

    worldwide_organisation = create(:worldwide_organisation)
    create(:about_corporate_information_page, organisation: nil, worldwide_organisation: worldwide_organisation, body: 'pre-edit body')
    get :show, params: { id: worldwide_organisation }
    assert_select ".description", text: "pre-edit body"

    draft_cip = create(:draft_about_corporate_information_page, organisation: nil, worldwide_organisation: worldwide_organisation, body: 'post-edit body')

    get :show, params: { id: worldwide_organisation }
    assert_select ".description", text: "pre-edit body"

    get :show, params: { id: worldwide_organisation, preview: draft_cip.id }
    assert_select ".description", text: "post-edit body"
  end

  view_test "not showing a preview of draft content when requested and a user is not logged in" do
    worldwide_organisation = create(:worldwide_organisation)
    create(:about_corporate_information_page, organisation: nil, worldwide_organisation: worldwide_organisation, body: 'pre-edit body')
    get :show, params: { id: worldwide_organisation }
    assert_select ".description", text: "pre-edit body"

    draft_cip = create(:draft_about_corporate_information_page, organisation: nil, worldwide_organisation: worldwide_organisation, body: 'post-edit body')
    get :show, params: { id: worldwide_organisation, preview: draft_cip.id }
    assert_select ".description", text: "pre-edit body"
  end
end
