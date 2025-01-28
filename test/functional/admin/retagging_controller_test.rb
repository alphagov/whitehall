require "test_helper"

class Admin::RetaggingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to GET :index and see a textarea for CSV input" do
    get :index

    assert_select "form[action='/government/admin/retagging'][method='post']", count: 1
    assert_select "textarea[name='csv_input']", count: 1

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end

  test "Submitting a CSV with invalid data should show an error message" do
    csv_to_submit = <<~CSV
      Slug,New lead organisations,New supporting organisations,Document type
      /made-up-slug,government-digital-service,geospatial-commission,Publication
    CSV
    post :preview, params: { csv_input: csv_to_submit }

    assert_response :ok
    assert_template :index
    assert_equal flash[:alert], "Errors with CSV input: <br>Document not found: made-up-slug<br>Organisation not found: government-digital-service<br>Organisation not found: geospatial-commission"
  end
end
