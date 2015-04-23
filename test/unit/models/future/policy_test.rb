require 'test_helper'

module Future
  class PolicyTest < ActiveSupport::TestCase
    include ContentRegisterHelpers

    setup do
      stub_content_register_policies
    end

    test "#all returns all policy entries" do
      future_policies = Future::Policy.all

      assert_equal 2, future_policies.size
      assert_equal policy_1["content_id"], future_policies[0].content_id
      assert_equal policy_2["content_id"], future_policies[1].content_id
    end

    test "#find returns a specific policy entry" do
      future_policy = Future::Policy.find(policy_1["content_id"])

      assert_equal policy_1["content_id"], future_policy.content_id
      assert_equal policy_1["title"], future_policy.title
    end
  end
end
