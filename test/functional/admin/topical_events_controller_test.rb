require 'test_helper'

class Admin::TopicalEventsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  def setup
    @event = create(:topical_event)
  end

  view_test "about page should render layout common to all tabs" do
    get :about, id: @event.to_param
    assert_response :success
    assert_select 'h1', @event.name
    assert_select '.tabbable'
  end
end
