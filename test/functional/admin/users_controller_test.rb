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
      assert_select "input[name='user[email]'][type='text'][value='user@example.com']"
      assert_select "input[type='submit'][value='Save']"
    end
  end

  view_test "edit displays cancel link" do
    login_as create(:gds_editor)
    get :edit, id: @user.id

    assert_select ".or_cancel a[href='#{admin_user_path(@user)}']"
  end

  test "update saves changes" do
    login_as create(:gds_editor)
    put :update, id: @user.id, user: { email: "new-user@example.com" }

    @user.reload
    assert_equal "new-user@example.com", @user.email
  end

  test "update redirects to user page on success" do
    login_as create(:gds_editor)
    put :update, id: @user.id, user: { email: "new-user@example.com" }

    assert_redirected_to admin_user_path(@user)
  end

  test "update displays notice on success" do
    login_as create(:gds_editor)
    put :update, id: @user.id, user: { email: "new-user@example.com" }

    assert_equal "Your settings have been saved", flash[:notice]
  end

  view_test "update redisplays form on failure" do
    login_as create(:gds_editor)
    put :update, id: @user.id, user: { email: "invalid-email-address" }

    assert_template :edit
    assert_select "form" do
      assert_select "input[name='user[email]'][value='invalid-email-address']"
    end
  end

  view_test "update displays error message on failure" do
    login_as create(:gds_editor)
    put :update, id: @user.id, user: { email: "invalid-email-address" }

    assert_select ".errors li", text: "Email does not appear to be valid"
  end

  test "update does not allow organisation changes by just anyone" do
    login_as create(:user, name: "Another user")
    organisation = create(:organisation, name: "new org")
    put :update, id: @user.id, user: { organisation_id: organisation.id }
    assert_response :forbidden
  end

  test "update does allow organisation changes by gds editors" do
    login_as create(:gds_editor)
    organisation = create(:organisation, name: "new org")
    put :update, id: @user.id, user: { organisation_id: organisation.id }
    assert_equal organisation, @user.reload.organisation
  end
end
