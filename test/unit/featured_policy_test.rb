require 'test_helper'

class FeaturedPolicyTest < ActiveSupport::TestCase
  test "the order defaults to the end of the orgs policies" do
    org_1 = create(:organisation)
    org_2 = create(:organisation)

    create(:featured_policy, organisation: org_1)
    create(:featured_policy, organisation: org_2)
    create(:featured_policy, organisation: org_2)

    assert_equal [0], org_1.featured_policies.map(&:ordering)
    assert_equal [0, 1], org_2.featured_policies.map(&:ordering)
  end
end
