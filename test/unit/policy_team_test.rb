require "test_helper"

class PolicyTeamTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    policy_team = build(:policy_team, name: '')
    refute policy_team.valid?
  end

  test "should be invalid without an email" do
    policy_team = build(:policy_team, email: "")
    refute policy_team.valid?
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
