require "test_helper"

class Admin::EditionableWorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    feature_flags.switch! :editionable_worldwide_organisations, true
    login_as :writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :editionable_worldwide_organisation
  should_allow_editing_of :editionable_worldwide_organisation

  test "actions are forbidden when the editionable_worldwide_organisations feature flag is disabled" do
    feature_flags.switch! :editionable_worldwide_organisations, false
    worldwide_organisation = create(:editionable_worldwide_organisation)

    get :show, params: { id: worldwide_organisation.id }

    assert_response :forbidden
  end
end
