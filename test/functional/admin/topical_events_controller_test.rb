require 'test_helper'

class Admin::TopicalEventsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller
  
  view_test "should show govdelivery field for gds editors" do
    login_as :gds_editor

    get :new

    assert_select 'input#topical_event_govdelivery_url'
  end

  view_test "should not show govdelivery field for non gds admins" do
    get :new

    refute_select 'input#topical_event_govdelivery_url'
  end

end
