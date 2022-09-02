require "test_helper"

class Admin::LicencesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @licence = create(:licence)
    @sector = create(:sector)
    @activity = create(:activity, sectors: [@sector])
  end

  should_be_an_admin_controller

  test "GET :show licence details" do
    get :show, params: { id: @licence.id }

    assert_response :success
    assert_template :show
    assert_equal @licence, assigns(:licence)
  end
end
