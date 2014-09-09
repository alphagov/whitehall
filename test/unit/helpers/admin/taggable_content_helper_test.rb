require 'test_helper'

class Admin::TaggableContentHelperTest < ActionView::TestCase

  test '#taggable_topics_container returns an array of name/ID pairs for all Topics' do
    topic_b = create(:topic, name: 'Topic B')
    topic_a = create(:topic, name: 'Topic A')
    topic_c = create(:topic, name: 'Topic C')

    assert_equal [
      ['Topic A', topic_a.id],
      ['Topic B', topic_b.id],
      ['Topic C', topic_c.id],
    ], taggable_topics_container
  end
end
