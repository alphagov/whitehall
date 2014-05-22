require 'test_helper'

class Admin::SitewideSettingsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  [:index, :edit, :update].each do |action_method|
    test "GDS editor permission required to access #{action_method}" do
      login_as :departmental_editor
      get action_method
      assert_response 403
    end
  end

  test "PUT on :update updates the sitewide setting" do
    sitewide_setting = create(:sitewide_setting)
    put :update, id: sitewide_setting, :sitewide_setting => {:on => true, :govspeak => "govspeak text"}

    assert_equal 'govspeak text', sitewide_setting.reload.govspeak
    assert_equal true, sitewide_setting.reload.on
    assert_redirected_to admin_sitewide_settings_path
  end

end
