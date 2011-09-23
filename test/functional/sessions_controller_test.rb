require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'should redirect to the admin page after logging in' do
    post :create, :name => 'George'
    assert_redirected_to admin_root_path
  end

  test 'warn if the user name supplied was empty' do
    post :create, :name => ''
    assert_template 'sessions/new'
    assert_equal "Name can't be blank", flash.now[:warning]
  end
end