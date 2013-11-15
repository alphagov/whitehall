require "test_helper"

class Edition::TopicsTest < ActiveSupport::TestCase
  class EditionWithTopics < Edition
    include Edition::Topics
  end

  setup do
    @topic = create(:topic)
  end

  test "#destroy should also remove the classification membership relationship" do
    edition = create(:draft_policy, topics: [@topic])
    relation = edition.classification_memberships.first
    edition.destroy
    refute ClassificationMembership.find_by_id(relation.id)
  end

  test "new edition of document that is a member of a topic should remain a member of that topic" do
    edition = create(:published_policy, topics: [@topic])
    new_edition = edition.create_draft(create(:policy_writer))

    assert_equal [@topic], new_edition.topics
  end

  test "edition should be invalid with neither topic nor topic suggestion" do
    edition = EditionWithTopics.new(attributes_for_edition)

    refute edition.valid?, "Edition should not be valid"
  end

  test "edition should be valid with an associated topic" do
    topic = build(:topic)
    edition = EditionWithTopics.new(attributes_for_edition.merge(topics: [topic]))

    assert edition.valid?, "Edition should be valid"
  end

  test "edition should be valid with an associated topic suggestion" do
    suggestion = TopicSuggestion.new(name: "a new topic")
    edition = EditionWithTopics.new(attributes_for_edition.merge(topic_suggestion: suggestion))

    assert edition.valid?, "Edition should be valid"
  end

private
  def attributes_for_edition
    attributes_for(:edition).merge(creator: build(:creator))
  end
end
