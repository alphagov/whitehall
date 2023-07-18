require "test_helper"

class Admin::OrganisationsAboutControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GET :show assings correctly" do
    organisation = create(:organisation)

    get :show, params: { id: organisation }

    assert_response :success
    assert_equal organisation, assigns(:organisation)
  end
end
