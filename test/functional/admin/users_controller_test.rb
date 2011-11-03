require "test_helper"

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user = create(:user, name: "user-name", email_address: "user@example.com")
    login_as(@user)
  end

  test "is an admin controller" do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "show displays user name and email address" do
    get :show

    assert_select ".user" do
      assert_select ".name", "user-name"
      assert_select ".email_address", "user@example.com"
    end
  end

  test "show displays edit button" do
    get :show

    assert_select ".actions" do
      assert_select "a[href='#{edit_admin_user_path}']", text: "Edit"
    end
  end

  test "edit displays form" do
    get :edit

    assert_select "form[action='#{admin_user_path}']" do
      assert_select "input[name='user[email_address]'][type='text'][value='user@example.com']"
      assert_select "input[type='submit'][value='Save']"
    end
  end

  test "update saves changes" do
    put :update, user: { email_address: "new-user@example.com" }

    @user.reload
    assert_equal "new-user@example.com", @user.email_address
  end

  test "update redirects to user page on success" do
    put :update, user: { email_address: "new-user@example.com" }

    assert_redirected_to admin_user_path
  end

  test "update displays notice on success" do
    put :update, user: { email_address: "new-user@example.com" }

    assert_equal "Your settings have been saved", flash[:notice]
  end

  test "update redisplays form on failure" do
    put :update, user: { email_address: "invalid-email-address" }

    assert_template :edit
    assert_select "form" do
      assert_select "input[name='user[email_address]'][value='invalid-email-address']"
    end
  end

  test "update displays error message on failure" do
    put :update, user: { email_address: "invalid-email-address" }

    assert_select ".errors li", text: "Email address does not appear to be valid"
  end
end