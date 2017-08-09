require 'test_helper'

class PolicyGroupsControllerTest < ActionController::TestCase
  test "should redirect to the slug URL if a policy id is provided" do
    policy_group = create(:policy_group)

    get :show, params: { id: policy_group.id }

    assert_redirected_to policy_group
  end
end
