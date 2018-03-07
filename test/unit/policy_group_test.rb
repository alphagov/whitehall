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
    policy_group = build(:policy_group, description: "policy-group-description")
    assert_equal "policy-group-description", policy_group.description
  end

  should_not_accept_footnotes_in(:description)

  test "publishes to the publishing API" do
    policy_group = create(:policy_group)
    Whitehall::PublishingApi.expects(:publish_async).with(policy_group).once
    policy_group.publish_to_publishing_api
  end

  test "#published_policies should return all tagged policies" do
    policy_group = create(:policy_group)
    assert_published_policies_returns_all_tagged_policies(policy_group)
  end

  test '#access_limited? returns false' do
    policy_group = FactoryBot.build(:policy_group)
    refute policy_group.access_limited?
  end

  test '#access_limited_object returns nil' do
    policy_group = FactoryBot.build(:policy_group)
    assert_nil policy_group.access_limited_object
  end

  test 'is always publicly visible' do
    policy_group = FactoryBot.build(:policy_group)
    assert policy_group.publicly_visible?
  end
end
