require "test_helper"

class Admin::BaseControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :gds_editor
  end

  view_test "should render new header component if login as a design system user" do
    @controller = Admin::DashboardController.new
    get :index

    assert_select ".gem-c-layout-header__logo", text: /Whitehall Publisher/
    assert_select ".govuk-header__navigation-item", text: "Dashboard"
  end

  view_test "should render legacy header component if login as a non design system user" do
    login_as :gds_editor
    @controller = Admin::DashboardController.new
    get :index

    assert_select ".govuk-header__navigation-item", false
    assert_select ".nav.navbar-nav", text: /Dashboard/
  end
end
