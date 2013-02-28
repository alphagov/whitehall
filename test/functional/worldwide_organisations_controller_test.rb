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

  test "show redirects to the api worldwide organisation endpoint when json is requested" do
    organisation = create(:worldwide_organisation)
    get :show, id: organisation.id, format: :json
    assert_redirected_to api_worldwide_organisation_path(organisation, format: :json)
  end
end
