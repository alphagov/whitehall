require "test_helper"

class Edition::PolicyTopicsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    policy_topic = create(:policy_topic)
    document = create(:draft_policy, policy_topics: [policy_topic])
    relation = document.policy_topic_memberships.first
    document.destroy
    refute PolicyTopicMembership.find_by_id(relation.id)
  end
end