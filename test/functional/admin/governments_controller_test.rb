require 'test_helper'

class Admin::GovernmentsControllerTest < ActionController::TestCase
  setup do
    @government = FactoryGirl.create(:government)
  end

  should_be_an_admin_controller

  [:new, :edit, :prepare_to_close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      login_as :gds_editor
      get action_method, id: @government.id
      assert_response 403
    end
  end

  [:create, :update, :close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      login_as :gds_editor
      post action_method, id: @government.id
      assert_response 403
    end
  end

  view_test "new should have the default start date of today" do
    login_as :gds_admin
    get :new
    assert_select "input[name='government[start_date]'][value='#{Date.today}']"
  end
end
