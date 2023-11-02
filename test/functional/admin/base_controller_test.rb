require "test_helper"

class Admin::BaseControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApi

  view_test "renders new header component if login as a design system user" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::NewDocumentController.new

    get :index

    assert_select ".gem-c-layout-header__logo", text: /Whitehall Publisher/
    assert_select ".govuk-header__navigation-item", text: "Dashboard"
  end

  view_test "highlights the 'Dashboard' tab when it is the currently selected tab- Main navigation" do
    login_as_preview_design_system_user :gds_editor
    @controller = Admin::DashboardController.new

    get :index

    assert_active_item("/government/admin")
    assert_not_active_item("/government/admin/users")
    assert_not_active_item("/government/admin/users/1")
  end

  view_test "highlights the 'All users' tab when it is the currently selected tab- Main navigation" do
    login_as_preview_design_system_user :gds_editor
    @controller = Admin::UsersController.new

    get :index

    assert_active_item("/government/admin/users")
    assert_not_active_item("/government/admin")
    assert_not_active_item("/government/admin/users/1")
  end

  view_test "highlights the current user name tab when it is the currently selected tab-Main navigation" do
    user = login_as_preview_design_system_user :gds_editor
    @controller = Admin::UsersController.new

    get :show, params: { id: user.id }

    assert_active_item("/government/admin/users/#{user.id}")
    assert_not_active_item("/government/admin")
    assert_not_active_item("/government/admin/users")
  end

  view_test "renders new sub-navigation header component if login as a design system user" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
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

  view_test "highlights the 'New documents' tab when it is the currently selected tab- Sub-navigation" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::NewDocumentController.new

    get :index

    assert_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/organisations/my-test-org/features")
    assert_not_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/more")
  end

  view_test "highlights the 'Documents' tab when it is the currently selected tab- Sub-navigation" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::EditionsController.new

    get :index, params: { type: 1 }

    assert_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/organisations/my-test-org/features")
    assert_not_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/more")
  end

  view_test "highlights the 'Statistics announcements' tab when it is the currently selected tab- Sub-navigation" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::StatisticsAnnouncementsController.new

    get :index

    assert_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/organisations/my-test-org/features")
    assert_not_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/more")
  end

  view_test "highlights the 'Features' tab when it is the currently selected tab- Sub-navigation" do
    my_test_org = create(:organisation, name: "my-test-org")
    login_as_preview_design_system_user :gds_editor, my_test_org
    @controller = Admin::OrganisationsController.new

    get :features, params: { id: my_test_org }

    assert_current_item("/government/admin/organisations/my-test-org/features")
    assert_not_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/more")
  end

  view_test "highlights the 'Corporate information pages' tab when it is the currently selected tab- Sub-navigation" do
    my_test_org = create(:organisation, name: "my-test-org")
    login_as_preview_design_system_user :gds_editor, my_test_org
    @controller = Admin::CorporateInformationPagesController.new

    get :index, params: { organisation_id: my_test_org }

    assert_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/organisations/my-test-org/features")
    assert_not_current_item("/government/admin/more")
  end

  view_test "highlights the 'More' tab when it is the currently selected tab- Sub-navigation" do
    login_as_preview_design_system_user :gds_editor, create(:organisation, name: "my-test-org")
    @controller = Admin::MoreController.new

    get :index

    assert_current_item("/government/admin/more")
    assert_not_current_item("/government/admin/new-document")
    assert_not_current_item("/government/admin/editions")
    assert_not_current_item("/government/admin/statistics_announcements")
    assert_not_current_item("/government/admin/organisations/my-test-org/corporate_information_pages")
    assert_not_current_item("/government/admin/organisations/my-test-org/features")
  end

  view_test "only renders non-organisation header links if not logged in" do
    # It's not possible, at the moment, to show the new design system layout if no user is signed in,
    # but once we remove the legacy layout, the design system will be the default layout. In order to
    # test this for now we stub some BaseController methods—this stubbing won't be necessary once the
    # design system transition has been completed.
    Admin::BaseController.any_instance.stubs(:show_new_header?).returns(true)
    Admin::BaseController.any_instance.stubs(:preview_design_system?).returns(true)
    @controller = Admin::NewDocumentController.new

    get :index

    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/organisations/my-test-org/features\"]", false
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/organisations/my-test-org/corporate_information_pages\"]", false

    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/new-document\"]"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/editions\"]"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/statistics_announcements\"]"
    assert_select ".app-c-sub-navigation__list .app-c-sub-navigation__list-item a[href=\"/government/admin/more\"]"
  end

private

  def assert_not_current_item(path)
    assert_select ".app-c-sub-navigation__list-item--current a[href=\"#{path}\"]", false
  end

  def assert_current_item(path)
    assert_select ".app-c-sub-navigation__list-item--current a[href=\"#{path}\"]"
  end

  def assert_not_active_item(path)
    assert_select ".govuk-header__navigation-item--active a[href=\"#{path}\"]", false
  end

  def assert_active_item(path)
    assert_select ".govuk-header__navigation-item--active a[href=\"#{path}\"]"
  end
end
