require "test_helper"

class Edition::TopicsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    topic = create(:topic)
    edition = create(:draft_policy, topics: [topic])
    relation = edition.classification_memberships.first
    edition.destroy
    refute ClassificationMembership.find_by_id(relation.id)
  end
end