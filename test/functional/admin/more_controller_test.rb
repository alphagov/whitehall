require "test_helper"

class Admin::MoreControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer
  end

  view_test "GET #index renders the 'More' page with a correctly formatted list of links" do
    get :index

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: "More"
    assert_select ".govuk-list"
    assert_select "a.govuk-link", text: "Cabinet ministers order"
  end
end
