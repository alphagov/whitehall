require "test_helper"

class Document::PolicyAreasTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    policy_area = create(:policy_area)
    document = create(:draft_policy, policy_areas: [policy_area])
    relation = document.policy_area_memberships.first
    document.destroy
    refute PolicyAreaMembership.find_by_id(relation.id)
  end
end