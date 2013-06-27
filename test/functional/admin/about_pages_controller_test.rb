require 'test_helper'

class Admin::AboutPagesControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @subject = create(:topical_event)
  end

  view_test "show page renders layout common to sibling tabs in admin UI" do
    get :show, topical_event_id: @subject.to_param
    assert_response :success
    assert_select 'h1', @subject.name
    assert_select '.tabbable'
  end
end
