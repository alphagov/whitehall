require "test_helper"

class Edition::TopicsTest < ActiveSupport::TestCase
  class EditionWithTopics < Edition
    include Edition::Topics
  end

  setup do
    @topic = create(:topic)
  end

  test "includes PublishesToPublishingApi" do
    assert Topic.new.is_a?(PublishesToPublishingApi)
  end

  test "#destroy should also remove the classification membership relationship" do
    edition = create(:draft_publication, topics: [@topic])
    relation = edition.classification_memberships.first
    edition.destroy
    refute ClassificationMembership.exists?(relation.id)
  end

  test "new edition of document that is a member of a topic should remain a member of that topic" do
    edition = create(:published_publication, topics: [@topic])
    new_edition = edition.create_draft(create(:writer))

    assert_equal [@topic], new_edition.topics
  end

  test "#title_with_topics returns the title and its topics's titles" do
    edition = EditionWithTopics.new(title: 'Edition Title', topics: [build(:topic, name: 'Topic 1')])

    assert_equal "Edition Title (Topic 1)", edition.title_with_topics

    edition.topics << build(:topic, name: 'Topic 2')

    assert_equal "Edition Title (Topic 1 and Topic 2)", edition.title_with_topics
  end

private

  def attributes_for_edition
    attributes_for(:edition).merge(creator: build(:creator))
  end
end
