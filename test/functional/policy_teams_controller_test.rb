require 'test_helper'

class PolicyTeamsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test "shows index" do
    policy_team1 = create(:policy_team, name: "Team 1")
    policy_team2 = create(:policy_team, name: "Team 2")

    get :index

    assert_select_object policy_team1
    assert_select_object policy_team2
  end

  view_test "show displays name and email" do
    policy_team = create(:policy_team)

    get :show, id: policy_team

    assert_select "h1", text: policy_team.name
    assert_select ".email a", text: policy_team.email
  end

  view_test "shows description using govspeak" do
    policy_team = create(:policy_team, description: "description [with link](http://example.com).")

    get :show, id: policy_team

    assert_select ".description" do
      assert_select "a[href='http://example.com']", "with link"
    end
  end

  view_test "show policies being worked on by the team" do
    policy_team = create(:policy_team)
    published_policy = create(:published_policy, policy_teams: [policy_team])
    unpublished_policy = create(:draft_policy, policy_teams: [policy_team])

    get :show, id: policy_team

    assert_select_object published_policy
    refute_select_object unpublished_policy
  end
end
