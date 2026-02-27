require "test_helper"

class Admin::BaseControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new({}))
  end

  view_test "renders header component with correct links" do
    login_as :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::NewDocumentController.new

    get :index

    assert_select ".gem-c-layout-header__logo", text: /Whitehall Publisher/
    assert_select ".govuk-service-navigation__item", text: "Dashboard"
    assert_select ".govuk-service-navigation__item", text: "View website"
    assert_select ".govuk-service-navigation__item", text: "Switch app"
    assert_select ".govuk-service-navigation__item", text: "Profile"
    assert_select ".govuk-service-navigation__item", text: "Logout"
    assert_select ".govuk-service-navigation__item", text: "All users"
  end

  view_test "highlights the 'Dashboard' tab when it is the currently selected tab- Main navigation" do
    login_as :gds_editor
    @controller = Admin::DashboardController.new

    get :index

    assert_active_item("/government/admin")
  end

  view_test "renders new sub-navigation header component if login as a design system user" do
    login_as :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::NewDocumentController.new

    get :index

    assert_select ".app-c-sub-navigation", count: 1
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/new-document\"]", text: "New document"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/editions\"]", text: "Documents"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/statistics_announcements\"]", text: "Statistics announcements"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/organisations/my-test-org/features\"]", text: "Featured documents"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/organisations/my-test-org/corporate_information_pages\"]", text: "Corporate information"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/more\"]", text: "More"
  end

  view_test "highlights the 'New document' tab when it is the currently selected tab- Sub-navigation" do
    login_as :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::NewDocumentController.new

    get :index

    assert_current_item("/government/admin/new-document")
  end

  view_test "dashboard page is inaccessible when maintenance mode is enabled" do
    test_strategy = Flipflop::FeatureSet.current.test!
    test_strategy.switch!(:maintenance_mode, true)
    login_as :gds_editor
    @controller = Admin::DashboardController.new
    get :index

    assert_response :service_unavailable
    assert_template "admin/errors/down_for_maintenance"
    test_strategy.switch!(:maintenance_mode, false)
  end

private

  def assert_current_item(path)
    assert_select ".app-c-sub-navigation__list-item--current", count: 1
    assert_select ".app-c-sub-navigation__list-item--current a[href=\"#{path}\"]"
  end

  def assert_active_item(path)
    assert_select ".govuk-service-navigation__item--active", count: 1
    assert_select ".govuk-service-navigation__item--active a[href=\"#{path}\"]"
  end
end
