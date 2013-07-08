require 'test_helper'

class AboutPagesControllerTest < ActionController::TestCase
  test "GET show responds with 404 if topical event found but no about page created" do
    topical_event = create(:topical_event)
    assert_raises ActiveRecord::RecordNotFound do
      get :show, topical_event_id: topical_event.to_param
    end
  end
end
