require "test_helper"

class PolicyTest < ActiveSupport::TestCase

  test "does not allow attachment" do
    refute build(:policy).allows_attachments?
  end

  test "should build a draft copy of the existing policy with inapplicable nations" do
    published_policy = create(:published_policy, inapplicable_nations: [Nation.wales, Nation.scotland])

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal published_policy.inapplicable_nations, draft_policy.inapplicable_nations
  end

  test "can belong to multiple policy areas" do
    policy_area_1 = create(:policy_area)
    policy_area_2 = create(:policy_area)
    policy = create(:policy, policy_areas: [policy_area_1, policy_area_2])
    assert_equal [policy_area_1, policy_area_2], policy.policy_areas.reload
  end
end