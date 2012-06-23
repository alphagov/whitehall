require 'test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should display a list of roles" do
    org_one = create(:organisation, name: "org-one")
    org_two = create(:organisation, name: "org-two")
    person = create(:person, forename: "person-name")
    ministerial_role = create(:ministerial_role, name: "ministerial-role", cabinet_member: true, organisations: [org_one, org_two])
    create(:role_appointment, role: ministerial_role, person: person)
    management_role = create(:board_member_role, name: "management-role", permanent_secretary: true, organisations: [org_one])
    military_role = create(:military_role, name: "military-role", organisations: [org_two])

    get :index

    assert_select ".roles" do
      assert_select_object ministerial_role do
        assert_select ".name", "ministerial-role"
        assert_select ".role_type", "Cabinet minister"
        assert_select ".organisations", "org-one and org-two"
        assert_select ".person", "person-name"
      end
      assert_select_object management_role do
        assert_select ".name", "management-role"
        assert_select ".role_type", "Permanent secretary"
        assert_select ".organisations", "org-one"
        assert_select ".person", "No one is assigned to this role"
      end
      assert_select_object military_role do
        assert_select ".name", "military-role"
        assert_select ".role_type", "Chief of staff"
        assert_select ".organisations", "org-two"
        assert_select ".person", "No one is assigned to this role"
      end
    end
  end

  test "index should order roles by organisation names versus role name" do
    org_A = create(:organisation, name: "A")
    org_C = create(:organisation, name: "C")
    org_B = create(:organisation, name: "B")
    role_A = create(:role, name: "name", organisations: [org_A])
    role_C = create(:role, name: "name", organisations: [org_C])
    role_B = create(:role, name: "name", organisations: [org_B])

    get :index

    assert_equal [role_A, role_B, role_C], assigns(:roles)
  end

  test "index should order roles by organisation names versus role type" do
    org_A = create(:organisation, name: "A")
    org_C = create(:organisation, name: "C")
    org_B = create(:organisation, name: "B")
    ministerial_role_A = create(:ministerial_role, name: "name", organisations: [org_A])
    ministerial_role_C = create(:ministerial_role, name: "name", organisations: [org_C])
    board_member_role = create(:board_member_role, name: "name", organisations: [org_B])

    get :index

    assert_equal [ministerial_role_A, board_member_role, ministerial_role_C], assigns(:roles)
  end

  test "index should order roles by role type (ministers first) versus role name" do
    org = create(:organisation)
    ministerial_role_B = create(:ministerial_role, name: "B", organisations: [org])
    board_member_role = create(:board_member_role, name: "A", organisations: [org])
    ministerial_role_A = create(:ministerial_role, name: "A", organisations: [org])

    get :index

    assert_equal [ministerial_role_A, ministerial_role_B, board_member_role], assigns(:roles)
  end

  test "index should order roles by role type with ministers first versus role permanent secretary status" do
    org = create(:organisation)
    ministerial_role = create(:ministerial_role, name: "name", organisations: [org])
    board_member_role_B = create(:board_member_role, name: "name", organisations: [org], permanent_secretary: false)
    board_member_role_A = create(:board_member_role, name: "name", organisations: [org], permanent_secretary: true)

    get :index

    assert_equal [ministerial_role, board_member_role_A, board_member_role_B], assigns(:roles)
  end

  test "index should order roles by permanent secretary status versus role name" do
    org = create(:organisation)
    permanent_secretary_role_B = create(:role, name: "B", organisations: [org], permanent_secretary: true)
    non_permanent_secretary_role = create(:role, name: "A", organisations: [org], permanent_secretary: false)
    permanent_secretary_role_A = create(:role, name: "A", organisations: [org], permanent_secretary: true)

    get :index

    assert_equal [permanent_secretary_role_A, permanent_secretary_role_B, non_permanent_secretary_role], assigns(:roles)
  end

  test "index should order roles by name all other things being equal" do
    org = create(:organisation)
    role_A = create(:role, name: "A", organisations: [org])
    role_C = create(:role, name: "C", organisations: [org])
    role_B = create(:role, name: "B", organisations: [org])

    get :index

    assert_equal [role_A, role_B, role_C], assigns(:roles)
  end

  test "index should display a link to create a new role" do
    get :index

    assert_select ".actions" do
      assert_select "a[href='#{new_admin_role_path}']"
    end
  end

  test "index should display links to edit an existing role" do
    role_one = create(:role)
    role_two = create(:role)

    get :index

    assert_select_object role_one do
      assert_select "a[href='#{edit_admin_role_path(role_one)}']"
    end
    assert_select_object role_two do
      assert_select "a[href='#{edit_admin_role_path(role_two)}']"
    end
  end

  test "provides delete buttons for destroyable roles" do
    destroyable_role = create(:role)
    edition = create(:edition)
    indestructable_role = create(:ministerial_role, editions: [edition])

    get :index

    assert_select_object destroyable_role do
      assert_select ".delete form[action='#{admin_role_path(destroyable_role)}']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "input[type='submit']"
      end
    end
    assert_select_object indestructable_role do
      refute_select ".delete form[action='#{admin_role_path(indestructable_role)}']"
    end
  end

  test "new should display form for creating a new role" do
    get :new

    assert_select "form[action='#{admin_roles_path}']" do
      assert_select "input[name='role[name]'][type='text']"
      assert_select "select[name='role[type]']"
      assert_select "select[name*='role[organisation_ids]']"
      assert_select "input[type='submit']"
    end
  end

  test "create should create a new ministerial role" do
    org_one, org_two = create(:organisation), create(:organisation)

    post :create, role: attributes_for(:ministerial_role,
      name: "role-name",
      type: "minister",
      organisation_ids: [org_one.id, org_two.id]
    )

    assert role = MinisterialRole.last
    assert_equal "role-name", role.name
    assert_equal [org_one, org_two], role.organisations
  end

  test "create should create a new board member role" do
    post :create, role: attributes_for(:board_member_role,
      type: "board_member",
    )

    assert role = BoardMemberRole.last
  end

  test "create should create a new military role" do
    post :create, role: attributes_for(:military_role,
      type: "chief_of_staff",
    )

    assert role = MilitaryRole.last
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

  test "edit should display form for updating an existing role" do
    org = create(:organisation, name: "org-name")
    role = create(:ministerial_role, name: "role-name", cabinet_member: true, permanent_secretary: false, organisations: [org])

    get :edit, id: role

    assert_select "form[action='#{admin_role_path(role)}']" do
      assert_select "input[name='role[name]'][value='role-name']"
      assert_select "select[name='role[type]']" do
        assert_select "option[selected='selected'][value='cabinet_minister']"
      end
      assert_select "select[name*='role[organisation_ids]']" do
        assert_select "option[selected='selected']", text: "org-name"
      end
      assert_select "input[type='submit']"
    end
  end

  test "update should modify existing role" do
    org_one, org_two = create(:organisation), create(:organisation)
    role = create(:ministerial_role, name: "role-name", cabinet_member: false, permanent_secretary: false, organisations: [org_one])

    put :update, id: role, role: {
      name: "new-name",
      type: "permanent_secretary",
      organisation_ids: [org_two.id]
    }

    role = Role.find(role.id)
    assert_equal BoardMemberRole, role.class
    assert_equal "new-name", role.name
    assert role.permanent_secretary?
    assert_equal [org_two], role.organisations
  end

  test "update should allow removal of all organisations" do
    org = create(:organisation)
    role = create(:role, organisations: [org])

    put :update, id: role, role: attributes_for(:role).except(:organisation_ids)

    role = Role.find(role.id)
    assert_equal [], role.organisations
  end

  test "update redirects to the index on success" do
    role = create(:role)

    put :update, id: role, role: attributes_for(:role)

    assert_redirected_to admin_roles_path
  end

  test "update should inform the user when a role is updated successfully" do
    role = create(:role)

    put :update, id:role, role: attributes_for(:role, name: "role-name")

    assert_equal %{"role-name" updated.}, flash[:notice]
  end

  test "update with invalid data should display errors" do
    role = create(:role)

    put :update, id: role, role: attributes_for(:role, name: nil)

    assert_select ".form-errors"
  end

  test "should be able to destroy a destroyable role" do
    role = create(:role, name: "Prime Minister")

    delete :destroy, id: role.id

    assert_redirected_to admin_roles_path
    refute Role.find_by_id(role.id)
    assert_equal %{"Prime Minister" destroyed.}, flash[:notice]
  end

  test "destroying an indestructible role" do
    role = create(:role)
    create(:role_appointment, role: role)

    delete :destroy, id: role.id

    assert_redirected_to admin_roles_path
    assert Role.find_by_id(role.id)
    assert_equal "Cannot destroy a role with appointments, organisations, or documents", flash[:alert]
  end
end