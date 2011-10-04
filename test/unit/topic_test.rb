require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    topic = build(:topic)
    assert topic.valid?
  end

  test 'should be invalid without a name' do
    topic = build(:topic, name: nil)
    assert_not topic.valid?
  end

  test 'should be invalid without unique name' do
    existing_topic = create(:topic)
    new_topic = build(:topic, name: existing_topic.name)
    assert_not new_topic.valid?
  end
end