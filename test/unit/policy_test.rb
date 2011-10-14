require "test_helper"

class PolicyTest < ActiveSupport::TestCase

  test "does not allow attachment" do
    refute build(:policy).allows_attachment?
  end

  test "should always be applicable to England" do
    policy = create(:published_policy)
    assert policy.nations.any? { |n| n.england? }

    policy = create(:published_policy, nations: [])
    assert policy.nations.any? { |n| n.england? }

    policy = create(:published_policy)
    policy.nations = [Nation.scotland]
    policy.save

    assert_equal 2, policy.nations.count, "all policies should"
    assert_same_elements [Nation.england, Nation.scotland], policy.nations
  end

end