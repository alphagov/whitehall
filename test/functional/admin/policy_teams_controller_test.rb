require "test_helper"

class Admin::PolicyTeamsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should list policy teams ordered alphabetically by email address" do
    team_b = create(:policy_team, email: "team-b@example.com")
    team_a = create(:policy_team, email: "team-a@example.com")

    get :index

    assert_equal [team_a, team_b], assigns(:policy_teams)
  end

  test "index should provide link to edit existing policy team" do
    policy_team = create(:policy_team, email: "team@example.com")

    get :index

    assert_select_object(policy_team) do
      assert_select "a[href='#{edit_admin_policy_team_path(policy_team)}']"
    end
  end

  test "new should build a new policy team" do
    get :new

    refute_nil policy_team = assigns(:policy_team)
    assert_instance_of(PolicyTeam, policy_team)
  end

  test "new should display policy team form" do
    get :new

    assert_select "form[action=#{admin_policy_teams_path}]" do
      assert_select "input[name='policy_team[email]']"
    end
  end

  test "create should create a new policy team" do
    post :create, policy_team: { email: "the-a-team@example.com" }

    refute_nil policy_team = PolicyTeam.last
    assert_equal "the-a-team@example.com", policy_team.email
  end

  test "create should redirect to policy team list on success" do
    post :create, policy_team: { email: "a-team@example.com" }

    assert_redirected_to admin_policy_teams_path
  end

  test "create should re-render form with errors on failure" do
    create(:policy_team, email: "duplicate@example.com")

    post :create, policy_team: { email: "duplicate@example.com" }

    assert_template "new"
    assert_select ".errors"
  end

  test "edit should display policy team form" do
    policy_team = create(:policy_team, email: "a-team@example.com")

    get :edit, id: policy_team

    assert_select "form[action=#{admin_policy_team_path(policy_team)}]" do
      assert_select "input[name='policy_team[email]'][value='a-team@example.com']"
    end
  end

  test "udpate should modify policy team" do
    policy_team = create(:policy_team, email: "original@example.com")

    put :update, id: policy_team, policy_team: { email: "new@example.com" }

    policy_team.reload
    assert_equal "new@example.com", policy_team.email
  end
end
