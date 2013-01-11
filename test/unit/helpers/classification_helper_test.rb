require 'test_helper'

class ClassificationHelperTest < ActionView::TestCase
  test "given a topic creates a topic url" do
    topic = create(:topic)
    assert_equal topic_url(topic), classification_url(topic)
  end

  test "given a topical_event creates a topical event url" do
    topical_event = create(:topical_event)
    assert_equal classification_url(topical_event), classification_url(topical_event)
  end

end
