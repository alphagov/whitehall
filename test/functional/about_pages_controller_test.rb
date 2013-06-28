require 'test_helper'

class AboutPagesControllerTest < ActionController::TestCase
  test "GET show responds with 404 if topical event found but no about page created" do
    subject = create(:topical_event)
    assert_raises ActiveRecord::RecordNotFound do
      get :show, topical_event_id: subject.to_param
    end
  end
end
