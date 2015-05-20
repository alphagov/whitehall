require "test_helper"
require "gds_api/test_helpers/rummager"

class PolicyGroupTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Rummager

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
    policy_group = build(:policy_group, description: "policy-group-description")
    assert_equal "policy-group-description", policy_group.description
  end

  should_not_accept_footnotes_in(:description)

  test "publishes to the publishing API" do
    policy_group = create(:policy_group)
    Whitehall::PublishingApi.expects(:publish_async).with(policy_group).once
    policy_group.publish_to_publishing_api
  end

  test "#published_policies should return the all policies" do
    policy_group = create(:policy_group)
    rummager_has_new_policies_for_every_type

    all_policy_titles = [
      "Welfare reform",
      "State Pension simplification",
      "State Pension age",
      "Poverty and social justice",
      "Older people",
      "Household energy",
      "Health and safety reform",
      "European funds",
      "Employment",
      "Child maintenance reform",
    ]

    assert_equal all_policy_titles, policy_group.published_policies.map(&:title)
  end
end
