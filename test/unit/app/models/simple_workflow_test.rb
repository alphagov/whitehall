require "test_helper"

class SimpleWorkflowTest < ActiveSupport::TestCase
  test "should be current when newly created" do
    assert_equal :current, create(:topical_event).current_state
  end

  test "should call destroyable? when trying to delete" do
    topic = create(:topical_event)
    topic.stubs(:destroyable?).returns(true)
    topic.delete!
    assert_equal :deleted, topic.reload.current_state
  end

  test "should not delete if destroyable returns false" do
    topic = create(:topical_event)
    topic.stubs(:destroyable?).returns(false)
    topic.delete!
    assert_equal :current, topic.current_state
  end

  test "should exclude deleted topics by default" do
    current_topic = create(:topical_event)
    create(:topical_event, state: "deleted")
    assert_equal [current_topic], TopicalEvent.all
  end
end
