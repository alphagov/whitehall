require 'test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "index should display a list of roles" do
    org_one = create(:organisation, name: "org-one")
    org_two = create(:organisation, name: "org-two")
    person = create(:person, forename: "person-name")
    ministerial_role = create(:ministerial_role, name: "ministerial-role", cabinet_member: true, organisations: [org_one, org_two])
    create(:role_appointment, role: ministerial_role, person: person)
    management_role = create(:board_member_role, name: "management-role", permanent_secretary: true, organisations: [org_one])
    military_role = create(:military_role, name: "military-role", organisations: [org_two])
    chief_professional_officer_role = create(:chief_professional_officer_role, name: "chief-professional-officer-role", organisations: [org_one])
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
      assert_select_object chief_professional_officer_role do
        assert_select ".name", "chief-professional-officer-role"
        assert_select ".role_type", "Chief professional officer"
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
    org_a = create(:organisation, name: "A")
    org_c = create(:organisation, name: "C")
    org_b = create(:organisation, name: "B")
    role_a = create(:ministerial_role, name: "name", organisations: [org_a])
    role_c = create(:ministerial_role, name: "name", organisations: [org_c])
    role_b = create(:ministerial_role, name: "name", organisations: [org_b])

    get :index

    assert_equal [role_a, role_b, role_c], assigns(:roles)
  end

  test "index should order roles by organisation names versus role type" do
    org_a = create(:organisation, name: "A")
    org_c = create(:organisation, name: "C")
    org_b = create(:organisation, name: "B")
    ministerial_role_a = create(:ministerial_role, name: "name", organisations: [org_a])
    ministerial_role_c = create(:ministerial_role, name: "name", organisations: [org_c])
    board_member_role = create(:board_member_role, name: "name", organisations: [org_b])

    get :index

    assert_equal [ministerial_role_a, board_member_role, ministerial_role_c], assigns(:roles)
  end

  test "index should order roles by role type (ministers first) versus role name" do
    org = create(:organisation)
    ministerial_role_b = create(:ministerial_role, name: "B", organisations: [org])
    board_member_role = create(:board_member_role, name: "A", organisations: [org])
    ministerial_role_a = create(:ministerial_role, name: "A", organisations: [org])

    get :index

    assert_equal [ministerial_role_a, ministerial_role_b, board_member_role], assigns(:roles)
  end

  test "index should order roles by role type with ministers first versus role permanent secretary status" do
    org = create(:organisation)
    ministerial_role = create(:ministerial_role, name: "name", organisations: [org])
    board_member_role_b = create(:board_member_role, name: "name", organisations: [org], permanent_secretary: false)
    board_member_role_a = create(:board_member_role, name: "name", organisations: [org], permanent_secretary: true)

    get :index

    assert_equal [ministerial_role, board_member_role_a, board_member_role_b], assigns(:roles)
  end

  test "index should order roles by permanent secretary status versus role name" do
    org = create(:organisation)
    permanent_secretary_role_b = create(:board_member_role, name: "B", organisations: [org], permanent_secretary: true)
    non_permanent_secretary_role = create(:board_member_role, name: "A", organisations: [org], permanent_secretary: false)
    permanent_secretary_role_a = create(:board_member_role, name: "A", organisations: [org], permanent_secretary: true)

    get :index

    assert_equal [permanent_secretary_role_a, permanent_secretary_role_b, non_permanent_secretary_role], assigns(:roles)
  end

  test "index should order roles by name all other things being equal" do
    org = create(:organisation)
    role_a = create(:board_member_role, name: "A", organisations: [org])
    role_c = create(:board_member_role, name: "C", organisations: [org])
    role_b = create(:board_member_role, name: "B", organisations: [org])

    get :index

    assert_equal [role_a, role_b, role_c], assigns(:roles)
  end

  view_test "index should display a link to create a new role" do
    get :index
    assert_select "a[href='#{new_admin_role_path}']"
  end

  view_test "index should display links to edit an existing role" do
    role_one = create(:board_member_role)
    role_two = create(:military_role)

    get :index

    assert_select_object role_one do
      assert_select "a[href='#{edit_admin_role_path(role_one)}']"
    end
    assert_select_object role_two do
      assert_select "a[href='#{edit_admin_role_path(role_two)}']"
    end
  end

  view_test "index should display link to manage translations for worldwide roles" do
    role = create(:ministerial_role)
    get :index

    assert_select_object role do
      assert_select "a[href=?]", admin_role_translations_path(role), text: "Manage translations"
    end
  end

  view_test "provides delete buttons for destroyable roles" do
    destroyable_role = create(:role_without_organisations)
    edition = create(:edition)
    indestructable_role = create(:ministerial_role)
    create(:role_appointment, editions: [edition])

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

  view_test "new should display form for creating a new role" do
    get :new

    assert_select "form[action='#{admin_roles_path}']" do
      assert_select "input[name='role[name]'][type='text']"
      assert_select "select[name='role[role_type]']"
      assert_select "select[name*='role[organisation_ids]']"
      assert_select "input[type='submit']"
    end
  end

  test "create should create a new ministerial role with a content_id" do
    org_one, org_two = create(:organisation), create(:organisation)

    post :create, params: {
      role: attributes_for(
        :ministerial_role,
        name: "role-name",
        role_type: "minister",
        organisation_ids: [org_one.id, org_two.id]
      )
    }

    assert role = MinisterialRole.last
    assert_equal "role-name", role.name
    assert_equal [org_one, org_two], role.organisations
    refute_nil role.content_id
  end

  test "create should create a new board level manager role" do
    post :create, params: {
      role: attributes_for(:board_member_role,
                           role_type: "board_level_manager")
    }

    assert role = BoardMemberRole.last
  end

  test "create should create a new military role" do
    post :create, params: {
      role: attributes_for(:military_role,
                           role_type: "chief_of_staff")
    }

    assert role = MilitaryRole.last
  end

  test "create should create a new special representative role" do
    post :create, params: {
      role: attributes_for(:special_representative_role,
                           role_type: "special_representative")
    }

    assert role = SpecialRepresentativeRole.last
  end

  test "create should create a new chief professional officer role" do
    post :create, params: {
      role: attributes_for(:chief_professional_officer_role,
                           role_type: "chief_professional_officer")
    }

    assert role = ChiefProfessionalOfficerRole.last
  end

  test "create redirects to the index on success" do
    post :create, params: { role: attributes_for(:role) }

    assert_redirected_to admin_roles_path
  end

  test "create should inform the user when a role is created successfully" do
    post :create, params: { role: attributes_for(:role, name: "role-name") }

    assert_equal %{"role-name" created.}, flash[:notice]
  end

  view_test "create with invalid data should display errors" do
    post :create, params: { role: attributes_for(:role, name: nil) }

    assert_select ".form-errors"
  end

  view_test "edit should display form for updating an existing role" do
    org = create(:organisation, name: "org-name")
    role = create(:board_member_role, name: "role-name", permanent_secretary: true, organisations: [org])

    get :edit, params: { id: role }

    assert_select "form[action='#{admin_role_path(role)}']" do
      assert_select "input[name='role[name]'][value='role-name']"
      assert_select "select[name='role[role_type]']" do
        assert_select "option[selected='selected'][value='permanent_secretary']"
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

    put :update, params: { id: role, role: {
      name: "new-name",
      role_type: "permanent_secretary",
      organisation_ids: [org_two.id]
    } }

    role = Role.find(role.id)
    assert_equal BoardMemberRole, role.class
    assert_equal "new-name", role.name
    assert role.permanent_secretary?
    assert_equal [org_two], role.organisations
  end

  test "update redirects to the index on success" do
    role = create(:role)

    put :update, params: { id: role, role: attributes_for(:role) }

    assert_redirected_to admin_roles_path
  end

  test "update should inform the user when a role is updated successfully" do
    role = create(:role)

    put :update, params: { id: role, role: attributes_for(:role, name: "role-name") }

    assert_equal %{"role-name" updated.}, flash[:notice]
  end

  view_test "update with invalid data should display errors" do
    role = create(:role)

    put :update, params: { id: role, role: attributes_for(:role, name: nil) }

    assert_select ".form-errors"
  end

  test "should be able to destroy a destroyable role" do
    role = create(:role_without_organisations, name: "Prime Minister")

    delete :destroy, params: { id: role.id }

    assert_redirected_to admin_roles_path
    refute Role.find_by(id: role.id)
    assert_equal %{"Prime Minister" destroyed.}, flash[:notice]
  end

  test "destroying an indestructible role" do
    role = create(:role)
    create(:role_appointment, role: role)

    delete :destroy, params: { id: role.id }

    assert_redirected_to admin_roles_path
    assert Role.find_by(id: role.id)
    assert_equal "Cannot destroy a role with appointments, organisations, or documents", flash[:alert]
  end
end
