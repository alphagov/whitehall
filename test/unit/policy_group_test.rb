require "test_helper"

class PolicyGroupTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    policy_group = build(:policy_group, name: '')
    refute policy_group.valid?
  end

  test "should be valid without an email" do
    policy_group = build(:policy_group, email: "")
    assert policy_group.valid?
  end

  test "should be valid without a unique email" do
    existing_policy_group = create(:policy_group)
    new_policy_group = build(:policy_group, email: existing_policy_group.email)
    assert new_policy_group.valid?
  end

  test "should be invalid without a valid email" do
    policy_group = build(:policy_group, email: "invalid-email")
    refute policy_group.valid?
  end

  test "should allow a description" do
    policy_group = build(:policy_group, description: "policy-team-description")
    assert_equal "policy-team-description", policy_group.description
  end

  should_not_accept_footnotes_in(:description)
end
