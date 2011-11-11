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
    role_one = create(:ministerial_role, name: "role-one", leader: false, organisations: [org_one, org_two])
    create(:role_appointment, role: role_one, person: person)
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

  test "index should order roles by role type with ministers first versus role leader" do
    org = create(:organisation)
    ministerial_role_B = create(:ministerial_role, name: "name", organisations: [org], leader: false)
    board_member_role = create(:board_member_role, name: "name", organisations: [org], leader: true)
    ministerial_role_A = create(:ministerial_role, name: "name", organisations: [org], leader: true)

    get :index

    assert_equal [ministerial_role_A, ministerial_role_B, board_member_role], assigns(:roles)
  end

  test "index should order roles by leader versus role name" do
    org = create(:organisation)
    leader_role_B = create(:role, name: "B", organisations: [org], leader: true)
    non_leader_role = create(:role, name: "A", organisations: [org], leader: false)
    leader_role_A = create(:role, name: "A", organisations: [org], leader: true)

    get :index

    assert_equal [leader_role_A, leader_role_B, non_leader_role], assigns(:roles)
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

  test "edit should display form for updating an existing role" do
    org = create(:organisation, name: "org-name")
    role = create(:ministerial_role, name: "role-name", leader: true, organisations: [org])

    get :edit, id: role

    assert_select "form[action='#{admin_role_path(role)}']" do
      assert_select "input[name='role[name]'][value='role-name']"
      assert_select "select[name='role[type]']" do
        assert_select "option[selected='selected'][value='MinisterialRole']"
      end
      assert_select "input[name='role[leader]'][value='1']"
      assert_select "select[name*='role[organisation_ids]']" do
        assert_select "option[selected='selected']", text: "org-name"
      end
      assert_select "input[type='submit']"
    end
  end

  test "edit should display fields for updating an existing appointment" do
    person = create(:person, name: "person-name")
    role = create(:ministerial_role, name: "role-name")
    create(:role_appointment, role: role, person: person)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
        assert_select "option[selected='selected']", text: "person-name"
      end
      assert_select "select[name*='role[role_appointments_attributes][0][started_at']", count: 3
      assert_select "select[name*='role[role_appointments_attributes][0][ended_at']", count: 3
      assert_select "input[name='role[role_appointments_attributes][0][role_id]'][type='hidden'][value='#{role.id}']"
    end
  end

  test "edit should display existing appointments in the order in which they started" do
    person_one = create(:person, name: "person-one")
    person_two = create(:person, name: "person-two")
    role = create(:ministerial_role, name: "role-name")
    create(:role_appointment, role: role, person: person_one, started_at: 1.year.ago)
    create(:role_appointment, role: role, person: person_two, started_at: 2.years.ago)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
        assert_select "option[selected='selected']", text: "person-two"
      end
      assert_select "select[name='role[role_appointments_attributes][1][person_id]']" do
        assert_select "option[selected='selected']", text: "person-one"
      end
    end
  end

  test "update should modify existing role" do
    org_one, org_two = create(:organisation), create(:organisation)
    role = create(:ministerial_role, name: "role-name", leader: true, organisations: [org_one])

    put :update, id: role, role: {
      name: "new-name",
      type: BoardMemberRole,
      leader: false,
      organisation_ids: [org_two.id]
    }

    role = Role.find(role.id)
    assert_equal BoardMemberRole, role.class
    assert_equal "new-name", role.name
    refute role.leader
    assert_equal [org_two], role.organisations
  end

  test "update should modify existing appointment" do
    person = create(:person, name: "person")
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role, person: person)
    another_person = create(:person, name: "another-person")

    put :update, id: role, role: {
      role_appointments_attributes: {
        "0" => {
          id: role_appointment.id,
          person_id: another_person.id,
          role_id: role.id,
          "started_at(1i)" => 2010, "started_at(2i)" => 6, "started_at(3i)" => 15,
          "ended_at(1i)" => 2011, "ended_at(2i)" => 7, "ended_at(3i)" => 23
        }
      }
    }

    role_appointment.reload
    assert_equal another_person, role_appointment.person
    assert_equal Time.zone.parse("2010-06-15"), role_appointment.started_at
    assert_equal Time.zone.parse("2011-07-23"), role_appointment.ended_at
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

  test 'updating with invalid data should not lose the appointment fields or values' do
    person = create(:person, name: "person")
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role, person: person)
    another_person = create(:person, name: "another-person")

    put :update, id: role, role: attributes_for(:role,
      name: nil
    ).merge(
      role_appointments_attributes: {
        "0" => {
          id: role_appointment.id,
          person_id: another_person.id,
          role_id: role.id,
          "started_at(1i)" => 2010, "started_at(2i)" => 6, "started_at(3i)" => 15,
          "ended_at(1i)" => 2011, "ended_at(2i)" => 7, "ended_at(3i)" => 23
        }
      }
    )

    assert_select "form#role_edit" do
      assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
        assert_select "option[selected='selected']", text: "another-person"
      end
      assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
      assert_select_role_appointment_date_select 0, "ended_at", [2011, 7, 23]
    end
  end

  private

  def assert_select_role_appointment_date_select(child_index, attribute_name, date)
    (0..2).each do |index|
      assert_select "select[name='role[role_appointments_attributes][#{child_index}][#{attribute_name}(#{index + 1}i)]']" do
        assert_select "option[selected='selected'][value='#{date[index]}']"
      end
    end
  end
end