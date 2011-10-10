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
    draft_policy = create(:draft_policy, topics: [topic_1])
    published_policy = create(:published_policy, topics: [topic_1])
    published_publication = create(:published_publication, topics: [topic_1])
    create(:published_policy, topics: [topic_2])

    assert_equal [published_policy], topic_1.reload.published_policies
  end

  test "should return a list of published publications" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_publication = create(:draft_publication, topics: [topic_1])
    published_publication = create(:published_publication, topics: [topic_1])
    published_policy = create(:published_policy, topics: [topic_1])
    create(:published_publication, topics: [topic_2])

    assert_equal [published_publication], topic_1.reload.published_publications
  end

  test "should return a list of topics with published documents" do
    published_policy = create(:published_policy)
    published_publication = create(:published_publication)
    draft_policy = create(:draft_policy)
    draft_publication = create(:draft_publication)
    topic_with_published_policy = create(:topic, documents: [published_policy])
    topic_with_published_publication = create(:topic, documents: [published_publication])
    topic_without_published_policy = create(:topic, documents: [draft_policy])
    topic_without_published_publication = create(:topic, documents: [draft_publication])

    assert_equal [topic_with_published_policy, topic_with_published_publication].to_set, Topic.with_published_documents.to_set
  end
end