require 'test_helper'

class PolicyTeamsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "show displays name and email" do
    policy_team = create(:policy_team)

    get :show, id: policy_team

    assert_select ".page-header h1", text: policy_team.name
    assert_select ".email a", text: policy_team.email
  end

  test "show policies being worked on by the team" do
    policy_team = create(:policy_team)
    published_policy = create(:published_policy, policy_team: policy_team)
    unpublished_policy = create(:draft_policy, policy_team: policy_team)

    get :show, id: policy_team

    assert_select_object published_policy
    refute_select_object unpublished_policy
  end
end
