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
end
