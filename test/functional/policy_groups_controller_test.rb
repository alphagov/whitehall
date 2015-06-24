require 'test_helper'
require "gds_api/test_helpers/rummager"

class PolicyGroupsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::Rummager

  setup do
    rummager_has_no_policies_for_any_type
  end

  test "show sets meta description" do
    policy_group = create(:policy_group, summary: 'my meta description')

    get :show, id: policy_group

    assert_equal 'my meta description', assigns(:meta_description)
  end

  view_test "should display the group's policies" do
    policy_group = create(:policy_group)
    rummager_has_policies_for_every_type

    get :show, id: policy_group

    assert_select ".policies" do
      assert_select "a[href='/government/policies/welfare-reform']", text: "Welfare reform"
    end
  end
end
