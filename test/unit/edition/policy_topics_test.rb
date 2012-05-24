require "test_helper"

class Edition::PolicyTopicsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    policy_topic = create(:policy_topic)
    edition = create(:draft_policy, policy_topics: [policy_topic])
    relation = edition.policy_topic_memberships.first
    edition.destroy
    refute PolicyTopicMembership.find_by_id(relation.id)
  end
end