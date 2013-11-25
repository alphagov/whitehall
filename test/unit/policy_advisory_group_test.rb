require "test_helper"

class PolicyAdvisoryGroupTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    policy_advisory_group = build(:policy_advisory_group, name: '')
    refute policy_advisory_group.valid?
  end

  test "should be valid without an email" do
    policy_advisory_group = build(:policy_advisory_group, email: "")
    assert policy_advisory_group.valid?
  end

  test "should be valid without a unique email" do
    existing_policy_advisory_group = create(:policy_advisory_group)
    new_policy_advisory_group = build(:policy_advisory_group, email: existing_policy_advisory_group.email)
    assert new_policy_advisory_group.valid?
  end

  test "should be invalid without a valid email" do
    policy_advisory_group = build(:policy_advisory_group, email: "invalid-email")
    refute policy_advisory_group.valid?
  end

  test "should allow a description" do
    policy_advisory_group = build(:policy_advisory_group, description: "policy-team-description")
    assert_equal "policy-team-description", policy_advisory_group.description
  end

  should_not_accept_footnotes_in(:description)
end
