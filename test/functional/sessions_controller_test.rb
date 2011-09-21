require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'should redirect to the root url after logging in' do
    post :create, :name => 'George'
    assert_redirected_to root_path
  end

  test 'warn if the user name supplied was empty' do
    post :create, :name => ''
    assert_template 'sessions/new'
    assert_equal "Name can't be blank", flash.now[:warning]
  end
end