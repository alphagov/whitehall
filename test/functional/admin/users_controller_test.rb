require "test_helper"

class Admin::UsersControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, name: "user-name", email: "user@example.com")
    login_as_preview_design_system_user :writer
  end

  should_be_an_admin_controller

  view_test "index shows list of enabled users" do
    disabled_user = create(:disabled_user)
    get :index

    assert_select ".govuk-table__cell", @user.name
    refute_select(".govuk-table__cell", text: %r{#{disabled_user.name}})
  end

  view_test "show displays user name and email address" do
    get :show, params: { id: @user.id }

    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Name"
    assert_select ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: @user.name
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Email"
    assert_select ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: @user.email
  end

  view_test "show displays edit if you are able to edit the record" do
    get :show, params: { id: @user.id }
    refute_select "a[href='#{edit_admin_user_path(@user)}']"

    login_as create(:gds_editor)
    get :show, params: { id: @user.id }
    assert_select "a[href='#{edit_admin_user_path(@user)}']"
  end

  test "edit only works if you are a GDS editor" do
    another_user = create(:user, name: "other user")
    get :edit, params: { id: another_user.id }
    assert_response :forbidden
  end

  view_test "edit displays form" do
    login_as_preview_design_system_user :gds_editor
    get :edit, params: { id: @user.id }
    assert_select "form[action='#{admin_user_path(@user)}']" do
      assert_select "button", text: "Save"
    end
  end

  view_test "edit displays cancel link" do
    login_as_preview_design_system_user :gds_editor
    get :edit, params: { id: @user.id }

    assert_select "a.govuk-link", text: "Cancel"
  end

  test "update saves world location changes by gds editors and redirects to :show" do
    login_as create(:gds_editor)
    world_location = create(:world_location)
    put :update, params: { id: @user.id, user: { world_location_ids: [world_location.id] } }

    assert_equal world_location, @user.reload.world_locations.first
    assert_redirected_to admin_user_path(@user)
  end

  test "update does not allow world locations changes by just anyone" do
    login_as create(:user, name: "Another user")
    world_location = create(:world_location)
    put :update, params: { id: @user.id, user: { world_location_ids: [world_location.id] } }
    assert_response :forbidden
  end

  view_test "show: displays Edit link if user has gds editor permission to edit the record." do
    login_as_preview_design_system_user(:gds_editor)

    get :show, params: { id: @user.id }

    assert_select ".govuk-summary-list__actions", text: /Edit/
  end

  view_test "show: hides Edit link if user has no gds editor permission to edit the record." do
    get :show, params: { id: @user.id }

    assert_select ".govuk-summary-list__actions", false
  end
end
