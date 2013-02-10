require "test_helper"

class Admin::PolicyTeamsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should list policy teams ordered alphabetically by name" do
    team_b = create(:policy_team, name: "team-b")
    team_a = create(:policy_team, name: "team-a")

    get :index

    assert_equal [team_a, team_b], assigns(:policy_teams)
  end

  view_test "index should provide link to edit existing policy team" do
    policy_team = create(:policy_team)

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

  view_test "new should display policy team form" do
    get :new

    assert_select "form[action=#{admin_policy_teams_path}]" do
      assert_select "input[name='policy_team[name]']"
      assert_select "input[name='policy_team[email]']"
      assert_select "textarea[name='policy_team[description]']"
    end
  end

  test "create should create a new policy team" do
    post :create, policy_team: { name: "the-a-team", email: "the-a-team@example.com", description: "guns for hire" }

    refute_nil policy_team = PolicyTeam.last
    assert_equal "the-a-team", policy_team.name
    assert_equal "the-a-team@example.com", policy_team.email
    assert_equal "guns for hire", policy_team.description
  end

  test "create should redirect to policy team list on success" do
    post :create, policy_team: { name: "a-team", email: "a-team@example.com" }

    assert_redirected_to admin_policy_teams_path
  end

  view_test "create should re-render form with errors on failure" do
    create(:policy_team, email: "duplicate@example.com")

    post :create, policy_team: { email: "duplicate@example.com" }

    assert_template "new"
    assert_select ".errors"
  end

  view_test "edit should display policy team form" do
    policy_team = create(:policy_team, name: "a-team", email: "a-team@example.com", description: "guns for hire")

    get :edit, id: policy_team

    assert_select "form[action=#{admin_policy_team_path(policy_team)}]" do
      assert_select "input[name='policy_team[name]'][value='a-team']"
      assert_select "input[name='policy_team[email]'][value='a-team@example.com']"
      assert_select "textarea[name='policy_team[description]']", "guns for hire"
    end
  end

  test "udpate should modify policy team" do
    policy_team = create(:policy_team, name: "original", email: "original@example.com", description: "original description")

    put :update, id: policy_team, policy_team: { name: "new", email: "new@example.com", description: "new description" }

    policy_team.reload
    assert_equal "new", policy_team.name
    assert_equal "new@example.com", policy_team.email
    assert_equal "new description", policy_team.description
  end
end
