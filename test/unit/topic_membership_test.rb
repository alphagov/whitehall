require "test_helper"

class TopicMembershipTest < ActiveSupport::TestCase
  test "should not be valid without policy" do
    topic_membership = build(:topic_membership, policy: nil)
    refute topic_membership.valid?
  end

  test "should not be valid without topic" do
    topic_membership = build(:topic_membership, topic: nil)
    refute topic_membership.valid?
  end
end