require "test_helper"

class PolicyTeamTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    policy_team = build(:policy_team, name: '')
    refute policy_team.valid?
  end

  test "should be valid without an email" do
    policy_team = build(:policy_team, email: "")
    assert policy_team.valid?
  end

  test "should be valid without a unique email" do
    existing_policy_team = create(:policy_team)
    new_policy_team = build(:policy_team, email: existing_policy_team.email)
    assert new_policy_team.valid?
  end

  test "should be invalid without a valid email" do
    policy_team = build(:policy_team, email: "invalid-email")
    refute policy_team.valid?
  end

  test "should allow a description" do
    policy_team = build(:policy_team, description: "policy-team-description")
    assert_equal "policy-team-description", policy_team.description
  end
end
