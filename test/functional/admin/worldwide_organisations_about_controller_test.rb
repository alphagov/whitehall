require "test_helper"

class Admin::WorldwideOrganisationsAboutControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  test "GET :show assigns correctly" do
    worldwide_organisation = create(:worldwide_organisation)

    get :show, params: { id: worldwide_organisation }

    assert_response :success
    assert_equal worldwide_organisation, assigns(:worldwide_organisation)
  end
end
