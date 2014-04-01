require 'test_helper'

class PolicyGroupsControllerTest < ActionController::TestCase
  test "show sets meta description" do
    policy_group = create(:policy_group, summary: 'my meta description')

    get :show, id: policy_group

    assert_equal 'my meta description', assigns(:meta_description)
  end
end
