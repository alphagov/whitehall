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

  test "should remove from search index on delete if Searchable is included" do
    topic = create(:topical_event)
    Whitehall::SearchIndex.expects(:delete).with(topic)
    topic.delete!
    assert_equal :deleted, topic.current_state
  end

  test "should not call rummager if Searchable is not included" do
    topic = create(:topical_event)
    TopicalEvent.any_instance.stubs(:remove_from_search_index).returns(NameError)
    Whitehall::SearchIndex.expects(:delete).never
    topic.delete!
    assert_equal :deleted, topic.current_state
  end

  test "should exclude deleted topics by default" do
    current_topic = create(:topical_event)
    create(:topical_event, state: "deleted")
    assert_equal [current_topic], TopicalEvent.all
  end
end
