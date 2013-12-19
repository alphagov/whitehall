require "test_helper"

class Admin::PolicyAdvisoryGroupsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  view_test "GET :index" do
    group = create(:policy_advisory_group)

    get :index

    assert_response :success
    assert_equal [group], assigns(:policy_advisory_groups)
  end

  view_test "GET :new" do
    get :new

    assert_response :success
  end

  test "POST :create" do
    post :create, policy_advisory_group: { name: 'Policy Forum' }

    assert_response :redirect
    assert_redirected_to admin_policy_advisory_groups_path
    assert_equal 'Policy Forum', PolicyAdvisoryGroup.last.name
  end

  view_test "GET :edit" do
    group = create(:policy_advisory_group)

    get :edit, id: group

    assert_response :success
    assert_equal group, assigns(:policy_advisory_group)
  end

  test "PUT :update" do
    group = create(:policy_advisory_group, name: 'Policy Forum')

    put :update, id: group, policy_advisory_group: { name: 'Policy Board' }

    assert_response :redirect
    assert_redirected_to admin_policy_advisory_groups_path
    assert_equal 'Policy Board', group.reload.name
  end

  test "DELETE :destroy is forbidden for writers" do
    group = create(:policy_advisory_group)

    delete :destroy, id: group

    assert_response :forbidden
    assert PolicyAdvisoryGroup.exists?(group)
  end

  test "DELETE :destroy works for GDS editors" do
    group = create(:policy_advisory_group)

    login_as :gds_editor
    delete :destroy, id: group

    assert_response :redirect
    assert_redirected_to admin_policy_advisory_groups_path
    refute PolicyAdvisoryGroup.exists?(group)
  end
end
