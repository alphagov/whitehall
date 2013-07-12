require 'test_helper'

class PolicyAdvisoryGroupsControllerTest < ActionController::TestCase
  test "show sets meta description" do
    policy_advisory_group = create(:policy_advisory_group, summary: 'my meta description')

    get :show, id: policy_advisory_group

    assert_equal 'my meta description', assigns(:meta_description)
  end
end
