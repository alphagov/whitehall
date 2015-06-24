require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  include ContentRegisterHelpers

  setup do
    stub_content_register_policies
  end

  test "#all returns all policy entries" do
    policies = Policy.all

    assert_equal 3, policies.size
    assert_equal policy_1["content_id"], policies[0].content_id
    assert_equal policy_2["content_id"], policies[1].content_id
  end

  test "#find returns a specific policy entry" do
    policy = Policy.find(policy_1["content_id"])

    assert_equal policy_1["content_id"], policy.content_id
    assert_equal policy_1["title"], policy.title
  end

  test "#policy_areas returns the policy areas associated with the policy" do
    stub_content_register_policies_with_policy_areas

    policy_1_object = Policy.find(policy_1["content_id"])
    policy_2_object = Policy.find(policy_2["content_id"])

    assert_equal policy_area_1["title"], policy_1_object.policy_areas.first.title
    assert_equal [policy_area_1["title"], policy_area_2["title"]] , policy_2_object.policy_areas.map(&:title)
  end
end
