require "test_helper"

class Admin::GetInvolvedControllerTest < ActionController::TestCase
  setup do
    login_as(:gds_editor)
  end

  should_be_an_admin_controller

  test "GET :index returns ok" do
    get :index

    assert_response :success
    assert_template "index"
  end
end
