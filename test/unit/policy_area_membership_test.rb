require "test_helper"

class PolicyAreaMembershipTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    policy_area_membership = build(:policy_area_membership)
    assert policy_area_membership.valid?
  end

  test "should not be valid without policy" do
    policy_area_membership = build(:policy_area_membership, policy: nil)
    refute policy_area_membership.valid?
  end

  test "should not be valid without policy area" do
    policy_area_membership = build(:policy_area_membership, policy_area: nil)
    refute policy_area_membership.valid?
  end
end