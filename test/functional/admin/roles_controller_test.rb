require 'test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "index should display a list of roles" do
    role_one = create(:role, name: "role-one")
    role_two = create(:role, name: "role-two")
    role_three = create(:role, name: "role-three")

    get :index

    assert_select ".roles" do
      assert_select_object role_one
      assert_select_object role_two
      assert_select_object role_three
    end
  end

  test "index should order roles by name" do
    role_A = create(:role, name: "A")
    role_C = create(:role, name: "C")
    role_B = create(:role, name: "B")

    get :index

    assert_equal [role_A, role_B, role_C], assigns(:roles)
  end
end