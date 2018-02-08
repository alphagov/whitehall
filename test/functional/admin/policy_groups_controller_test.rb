require "test_helper"

class Admin::PolicyGroupsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "GET :index" do
    group = create(:policy_group)

    get :index

    assert_response :success
    assert_equal [group], assigns(:policy_groups)
  end

  view_test "GET :new" do
    get :new

    assert_response :success
  end

  test "POST :create" do
    post :create, params: { policy_group: { name: 'Policy Forum' } }

    assert_response :redirect
    assert_redirected_to admin_policy_groups_path
    assert_equal 'Policy Forum', PolicyGroup.last.name
  end

  test "POST :create with valid params publishes event to policy_group_notifier" do
    Whitehall.policy_group_notifier.expects(:publish).with('create', is_a(PolicyGroup))

    post :create, params: { policy_group: { name: 'Policy Forum' } }
  end

  test "POST :create with invalid params does not publish event to policy_group_notifier" do
    Whitehall.policy_group_notifier.expects(:publish).never

    post :create, params: { policy_group: { name: '' } }
  end

  view_test "GET :edit" do
    group = create(:policy_group)

    get :edit, params: { id: group }

    assert_response :success
    assert_equal group, assigns(:policy_group)
  end

  test "PUT :update" do
    group = create(:policy_group, name: 'Policy Forum')

    put :update, params: { id: group, policy_group: { name: 'Policy Board' } }

    assert_response :redirect
    assert_redirected_to admin_policy_groups_path
    assert_equal 'Policy Board', group.reload.name
  end

  test "PUT :update with valid params publishes event to policy_group_notifier" do
    group = create(:policy_group, name: 'Policy Forum')
    Whitehall.policy_group_notifier.expects(:publish).with('update', group)

    put :update, params: { id: group, policy_group: { name: 'Policy Board' } }
  end

  test "PUT :update with invalid params does not publish event to policy_group_notifier" do
    group = create(:policy_group, name: 'Policy Forum')
    Whitehall.policy_group_notifier.expects(:publish).never

    put :update, params: { id: group, policy_group: { name: '' } }
  end

  test "DELETE :destroy is forbidden for writers" do
    group = create(:policy_group)

    delete :destroy, params: { id: group }

    assert_response :forbidden
    assert PolicyGroup.exists?(group.id)
  end

  test "DELETE :destroy works for GDS editors" do
    group = create(:policy_group)

    login_as :gds_editor
    delete :destroy, params: { id: group }

    assert_response :redirect
    assert_redirected_to admin_policy_groups_path
    refute PolicyGroup.exists?(group.id)
  end
end
