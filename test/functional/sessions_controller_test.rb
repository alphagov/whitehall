require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'should redirect to the admin page after logging in' do
    post :create, name: 'George'
    assert_redirected_to admin_root_path
  end

  test 'warn if the user name supplied was empty' do
    post :create, name: ''
    assert_template 'sessions/new'
    assert_equal "Name can't be blank", flash.now[:alert]
  end

  test 'should create a departmental editor if the flag was checked' do
    post :create, name: 'Eddie Edtior', departmental_editor: true
    user = User.last
    assert user.departmental_editor?
  end

  test 'should set the current user to nil' do
    session[:user_id] = 1
    delete :destroy
    assert_nil session[:user_id]
  end

  test 'should redirect to the login page' do
    delete :destroy
    assert_redirected_to login_path
  end
end