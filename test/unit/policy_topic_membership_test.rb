require "test_helper"

class PolicyTopicMembershipTest < ActiveSupport::TestCase
  test "should not be valid without policy" do
    policy_topic_membership = build(:policy_topic_membership, policy: nil)
    refute policy_topic_membership.valid?
  end

  test "should not be valid without policy topic" do
    policy_topic_membership = build(:policy_topic_membership, policy_topic: nil)
    refute policy_topic_membership.valid?
  end
end