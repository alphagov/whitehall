require "test_helper"

class Admin::RetaggingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to GET :index and see a textarea for CSV input" do
    get :index

    assert_select "form[action='#'][method='post']", count: 1
    assert_select "textarea[name='csv_input']", count: 1

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end
end
