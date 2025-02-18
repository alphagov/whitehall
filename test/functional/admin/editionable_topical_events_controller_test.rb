require "test_helper"

class Admin::EditionableTopicalEventsControllerTest < ActionController::TestCase
  setup do
    feature_flags.switch! :editionable_topical_events, true
    login_as :writer
  end

  should_be_an_admin_controller

  # should_allow_creating_of :editionable_topical_event
  # should_allow_editing_of :editionable_topical_event

  test "actions are forbidden when the editionable_topical_events feature flag is disabled" do
    feature_flags.switch! :editionable_topical_events, false
    topical_event = create(:editionable_topical_event)

    get :show, params: { id: topical_event.id }

    assert_response :forbidden
  end
end
