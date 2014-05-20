require 'test_helper'

class Admin::SitewideSettingsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  [:index, :edit, :update].each do |action_method|
    test "GDS editor permission required to access #{action_method}" do
      login_as :departmental_editor
      get action_method
      assert_response 403
    end
  end

end
