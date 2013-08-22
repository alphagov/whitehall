require "test_helper"

class Edition::TopicsTest < ActiveSupport::TestCase
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
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    assert_equal @topic, new_edition.topics.first
  end
end
