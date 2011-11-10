require 'test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "index should display a list of roles" do
    org_one = create(:organisation, name: "org-one")
    org_two = create(:organisation, name: "org-two")
    person = create(:person, name: "person-name")
    role_one = create(:ministerial_role, name: "role-one", leader: false, organisations: [org_one, org_two], people: [person])
    role_two = create(:board_member_role, name: "role-two", leader: true, organisations: [org_one])

    get :index

    assert_select ".roles" do
      assert_select_object role_one do
        assert_select ".name", "role-one"
        assert_select ".type", "Ministerial"
        assert_select ".leader", "No"
        assert_select ".organisations", "org-one and org-two"
        assert_select ".person", "person-name"
      end
      assert_select_object role_two do
        assert_select ".name", "role-two"
        assert_select ".type", "Board member"
        assert_select ".leader", "Yes"
        assert_select ".organisations", "org-one"
        assert_select ".person", "No one is assigned to this role"
      end
    end
  end

  test "index should order roles by name" do
    role_A = create(:role, name: "A")
    role_C = create(:role, name: "C")
    role_B = create(:role, name: "B")

    get :index

    assert_equal [role_A, role_B, role_C], assigns(:roles)
  end

  test "index should display a link to create a new role" do
    get :index

    assert_select ".actions" do
      assert_select "a[href='#{new_admin_role_path}']"
    end
  end

  test "new should display form for creating a new role" do
    get :new

    assert_select "form[action='#{admin_roles_path}']" do
      assert_select "input[name='role[name]'][type='text']"
      assert_select "select[name='role[type]']"
      assert_select "input[name='role[leader]'][type='checkbox']"
      assert_select "select[name*='role[organisation_ids]']"
      assert_select "input[type='submit']"
    end
  end

  test "create should create a new role" do
    org_one, org_two = create(:organisation), create(:organisation)

    post :create, role: attributes_for(:role,
      name: "role-name",
      type: MinisterialRole,
      leader: true,
      organisation_ids: [org_one.id, org_two.id]
    )

    assert role = MinisterialRole.last
    assert_equal "role-name", role.name
    assert role.leader
    assert_equal [org_one, org_two], role.organisations
  end

  test "create redirects to the index on success" do
    post :create, role: attributes_for(:role)

    assert_redirected_to admin_roles_path
  end

  test "create should inform the user when a role is created successfully" do
    post :create, role: attributes_for(:role, name: "role-name")

    assert_equal %{"role-name" created.}, flash[:notice]
  end

  test "create with invalid data should display errors" do
    post :create, role: attributes_for(:role, name: nil)

    assert_select ".form-errors"
  end
end