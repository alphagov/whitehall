require "test_helper"

class Admin::FindInAdminBookmarkletControllerTest < ActionController::TestCase
  view_test "should render the Find in Admin Bookmarklet index page" do
    get :index

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: "'Find in admin' bookmarklet"
    assert_select ".govuk-button", text: "Find in admin"
  end
end
