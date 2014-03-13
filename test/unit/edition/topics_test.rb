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
    refute ClassificationMembership.exists?(relation)
  end

  test "new edition of document that is a member of a topic should remain a member of that topic" do
    edition = create(:published_policy, topics: [@topic])
    new_edition = edition.create_draft(create(:policy_writer))

    assert_equal [@topic], new_edition.topics
  end

  test "edition should be invalid without a topic" do
    edition = EditionWithTopics.new(attributes_for_edition)

    refute edition.valid?, "Edition should not be valid"
    assert_match /at least one required/, edition.errors[:topics].first
  end

  test "imported editions are valid without any topics" do
    edition = EditionWithTopics.new(attributes_for_edition.merge(state: 'imported'))

    assert edition.valid?
  end

private
  def attributes_for_edition
    attributes_for(:edition).merge(creator: build(:creator))
  end
end
