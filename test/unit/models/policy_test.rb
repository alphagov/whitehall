require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  test "#all returns all policy entries" do
    policies = Policy.all

    assert_equal 7, policies.size
    assert_equal policy_1["content_id"], policies[0].content_id
    assert_equal policy_2["content_id"], policies[1].content_id
  end

  test "#find returns a specific policy entry" do
    policy = Policy.find(policy_1["content_id"])

    assert_equal policy_1["content_id"], policy.content_id
    assert_equal policy_1["title"], policy.title
  end

  test "#all returns an empty array if publishing api errors" do
    publishing_api_isnt_available

    assert_raises(GdsApi::HTTPServerError) { Policy.all }
  end
end
