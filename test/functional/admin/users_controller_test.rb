require "test_helper"

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user = create(:user, name: "user-name", email: "user@example.com")
    login_as(@user)
  end

  should_be_an_admin_controller

  view_test "index shows list of users" do
    get :index

    assert_select("tr:last-child td.name", text: %r{#{@user.name}})
  end

  view_test "show displays user name and email address" do
    get :show, id: @user.id

    assert_select ".user .settings" do
      assert_select ".name", "user-name"
      assert_select ".email", "user@example.com"
    end
  end

  view_test "show displays edit if you are able to edit the record" do
    get :show, id: @user.id
    assert_select ".actions" do
      refute_select "a[href='#{edit_admin_user_path(@user)}']"
    end

    login_as create(:gds_editor)
    get :show, id: @user.id
    assert_select ".actions" do
      assert_select "a[href='#{edit_admin_user_path(@user)}']"
    end
  end

  test "edit only works if you are a GDS editor" do
    another_user = create(:user, name: "other user")
    get :edit, id: another_user.id
    assert_response :forbidden
  end

  view_test "edit displays form" do
    login_as create(:gds_editor)
    get :edit, id: @user.id

    assert_select "form[action='#{admin_user_path(@user)}']" do
      assert_select "input[type='submit'][value='Save']"
    end
  end

  view_test "edit displays cancel link" do
    login_as create(:gds_editor)
    get :edit, id: @user.id

    assert_select ".or_cancel a[href='#{admin_user_path(@user)}']"
  end

  test "update saves world location changes by gds editors and redirects to :show" do
    login_as create(:gds_editor)
    world_location = create(:world_location)
    put :update, id: @user.id, user: { world_location_ids: [world_location.id] }

    assert_equal world_location, @user.reload.world_locations.first
    assert_redirected_to admin_user_path(@user)
  end

  test "update does not allow world locations changes by just anyone" do
    login_as create(:user, name: "Another user")
    world_location = create(:world_location)
    put :update, id: @user.id, user: { world_location_ids: [world_location.id] }
    assert_response :forbidden
  end
end
