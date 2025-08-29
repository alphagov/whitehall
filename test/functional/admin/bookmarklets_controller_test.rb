require "test_helper"

class Admin::BookmarkletsControllerTest < ActionController::TestCase
  view_test "should render the Bookmarklets index page" do
    get :index

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: "Whitehall bookmarklets"
    assert_select ".govuk-button", text: "Find in admin"
    assert_select ".govuk-button", text: "Find a PDF publication page in Whitehall"
  end
end
