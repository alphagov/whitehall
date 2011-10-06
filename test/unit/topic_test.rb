require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    topic = build(:topic)
    assert topic.valid?
  end

  test 'should be invalid without a name' do
    topic = build(:topic, name: nil)
    refute topic.valid?
  end

  test 'should be invalid without a unique name' do
    existing_topic = create(:topic)
    new_topic = build(:topic, name: existing_topic.name)
    refute new_topic.valid?
  end

  test 'should be invalid without a description' do
    topic = build(:topic, description: nil)
    refute topic.valid?
  end

  test "should return a list of published policies" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_policy = create(:policy)
    published_policy = create(:policy)
    published_publication = create(:publication)
    create(:draft_edition, document: draft_policy, topics: [topic_1])
    create(:published_edition, document: published_policy, topics: [topic_1])
    create(:published_edition, document: published_publication, topics: [topic_1])
    create(:published_edition, topics: [topic_2])

    assert_equal [published_policy], topic_1.reload.published_policies
  end

  test "should return a list of published publications" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_publication = create(:publication)
    published_publication = create(:publication)
    published_policy = create(:policy)
    create(:draft_edition, document: draft_publication, topics: [topic_1])
    create(:published_edition, document: published_publication, topics: [topic_1])
    create(:published_edition, document: published_policy, topics: [topic_1])
    create(:published_edition, topics: [topic_2])

    assert_equal [published_publication], topic_1.reload.published_publications
  end
end