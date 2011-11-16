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

  test "provides delete buttons for destroyable roles" do
    destroyable_role = create(:role)
    document = create(:document)
    indestructable_role = create(:role, documents: [document])

    get :index

    assert_select_object destroyable_role do
      assert_select ".delete form[action='#{admin_role_path(destroyable_role)}']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "input[type='submit']"
      end
    end
    assert_select_object indestructable_role do
      assert_select ".delete form[action='#{admin_role_path(indestructable_role)}']", count: 0
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

  test "new should display fields for creating one new appointment" do
    get :new

    assert_select "form#role_new" do
      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select "select[name*='role[role_appointments_attributes][0][started_at']", count: 3
      end
    end
  end

  test "new should not display ended_at select for new appointment" do
    get :new

    assert_select "form#role_new" do
      assert_select "select[name*='role[role_appointments_attributes][0][ended_at']", count: 0
    end
  end

  test "new should not display checkbox for deleting new appointment" do
    get :new

    assert_select "form#role_new" do
      assert_select "input[name='role[role_appointments_attributes][0][_destroy]'][type='checkbox']", count: 0
    end
  end

  test "create should create a new ministerial role" do
    org_one, org_two = create(:organisation), create(:organisation)

    post :create, role: attributes_for(:ministerial_role,
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

  test "create should create a new board member role" do
    post :create, role: attributes_for(:board_member_role,
      type: BoardMemberRole,
    )

    assert role = BoardMemberRole.last
  end

  test "create should create a new appointment" do
    person = create(:person)

    post :create, role: attributes_for(:role, role_appointments_attributes_for(
      { person: person, started_at: "2010-06-15" }
    ))

    assert role = MinisterialRole.last
    assert appointment = role.role_appointments.last
    assert_equal person, appointment.person
    assert_equal role, appointment.role
    assert_equal Time.zone.parse("2010-06-15"), appointment.started_at
    assert_nil appointment.ended_at
  end

  test "create should not create a new appointment if all fields are blank" do
    post :create, role: attributes_for(:role, role_appointments_attributes_for(
      { person: nil, started_at: nil }
    ))

    assert_select ".form-errors", count: 0
    assert role = MinisterialRole.last
    assert_equal 0, role.role_appointments.length
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
    post :create, role: attributes_for(:role, name: nil, role_appointments_attributes: {})

    assert_select ".form-errors"
  end

  test 'create with invalid role data should not lose or duplicate the appointment fields or values' do
    person = create(:person, name: "person-name")

    post :create, role: attributes_for(:role, name: nil).merge(role_appointments_attributes_for(
      { person: person, started_at: "2010-06-15" }
    ))

    assert_select "form#role_new" do
      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
          assert_select "option[selected='selected']", text: "person-name"
        end
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
      end
    end
  end

  test 'create with invalid role data and blank new appointment should not lose or duplicate the appointment fields or values' do
    post :create, role: attributes_for(:role, name: nil).merge(role_appointments_attributes_for(
      { person: nil, started_at: nil }
    ))

    assert_select "form#role_new" do
      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select_role_appointment_date_select 0, "started_at", ["", "", ""]
      end
    end
  end

  test 'create with invalid appointment data should not lose or duplicate the appointment fields or values' do
    post :create, role: attributes_for(:role, role_appointments_attributes_for(
      { person: nil, started_at: "2010-06-15" }
    ))

    assert_select "form#role_edit" do
      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
      end
    end
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
    role = create(:ministerial_role)
    create(:role_appointment, role: role, person: person)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
        assert_select "option[selected='selected']", text: "person-name"
      end
      assert_select "select[name*='role[role_appointments_attributes][0][started_at']", count: 3
      assert_select "select[name*='role[role_appointments_attributes][0][ended_at']", count: 3
    end
  end

  test "edit should display checkbox for deleting existing appointment" do
    role = create(:ministerial_role, name: "role-name")
    create(:role_appointment, role: role)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "input[name='role[role_appointments_attributes][0][_destroy]'][type='checkbox']"
    end
  end

  test "edit should not display checkbox for deleting existing indestructible appointment" do
    role = create(:ministerial_role)
    create(:role_appointment, role: role, speeches: [create(:speech)])

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "input[name='role[role_appointments_attributes][0][_destroy]'][type='checkbox']", count: 0
    end
  end

  test "edit should display existing appointments in the order in which they started" do
    person_one = create(:person, name: "person-one")
    person_two = create(:person, name: "person-two")
    role = create(:ministerial_role)
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

  test "edit should display fields for creating one new appointment" do
    role = create(:ministerial_role)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select "select[name*='role[role_appointments_attributes][0][started_at']", count: 3
      end
    end
  end

  test "edit should not display ended_at select for new appointment" do
    role = create(:ministerial_role)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "select[name*='role[role_appointments_attributes][0][ended_at']", count: 0
    end
  end

  test "edit should not display checkbox for deleting new appointment" do
    role = create(:ministerial_role)

    get :edit, id: role

    assert_select "form#role_edit" do
      assert_select "input[name='role[role_appointments_attributes][0][_destroy]'][type='checkbox']", count: 0
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

  test "update should not change type if no type supplied" do
    role = create(:board_member_role)

    put :update, id: role, role: { type: nil }

    role = Role.find(role.id)
    assert_equal BoardMemberRole, role.class
  end

  test "update should modify existing appointment" do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)
    another_person = create(:person, name: "another-person")

    put :update, id: role, role: role_appointments_attributes_for(
      { role_appointment: role_appointment, person: another_person, started_at: "2010-06-15", ended_at: "2011-07-23" }
    )

    role_appointment.reload
    assert_equal another_person, role_appointment.person
    assert_equal Time.zone.parse("2010-06-15"), role_appointment.started_at
    assert_equal Time.zone.parse("2011-07-23"), role_appointment.ended_at
  end

  test "update should destroy existing appointment" do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)

    put :update, id: role, role: role_appointments_attributes_for(
      { role_appointment: role_appointment, _destroy: true }
    )

    refute role.role_appointments.find_by_id(role_appointment.id)
  end

  test "update should create a new appointment" do
    role = create(:ministerial_role)
    person = create(:person)

    put :update, id: role, role: role.attributes.merge(role_appointments_attributes_for(
      { person: person, started_at: "2010-06-15" }
    ))

    role.reload
    assert appointment = role.role_appointments.last
    assert_equal person, appointment.person
    assert_equal role, appointment.role
    assert_equal Time.zone.parse("2010-06-15"), appointment.started_at
    assert_nil appointment.ended_at
  end

  test "update should not create a new appointment if all fields are blank" do
    role = create(:ministerial_role)

    put :update, id: role, role: role.attributes.merge(role_appointments_attributes_for(
      { person: nil, started_at: nil }
    ))

    assert_select ".form-errors", count: 0
    role.reload
    assert_equal 0, role.role_appointments.length
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

  test 'update with invalid role data and blank new appointment should not lose or duplicate the appointment fields or values' do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)
    another_person = create(:person, name: "another-person")

    put :update, id: role, role: attributes_for(:role, name: nil).merge(role_appointments_attributes_for(
      { role_appointment: role_appointment, person: another_person, started_at: "2010-06-15", ended_at: "2011-07-23" },
      { person: nil, started_at: nil }
    ))

    assert_select "form#role_edit" do
      assert_select ".previous.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
          assert_select "option[selected='selected']", text: "another-person"
        end
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
        assert_select_role_appointment_date_select 0, "ended_at", [2011, 7, 23]
      end
      assert_select ".new.appointment", count: 1
    end
  end

  test 'update with invalid role data and populated new appointment should not lose or duplicate the appointment fields or values' do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)
    another_person = create(:person, name: "another-person")

    put :update, id: role, role: attributes_for(:role, name: nil).merge(role_appointments_attributes_for(
      { role_appointment: role_appointment, person: another_person, started_at: "2010-06-15", ended_at: "2011-07-23" },
      { person: nil, started_at: "2011-07-23" }
    ))

    assert_select "form#role_edit" do
      assert_select ".previous.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']" do
          assert_select "option[selected='selected']", text: "another-person"
        end
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
        assert_select_role_appointment_date_select 0, "ended_at", [2011, 7, 23]
      end
      assert_select ".new.appointment", count: 1
    end
  end

  test 'update with invalid appointment data and blank new appointment should not lose or duplicate the appointment fields or values' do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)

    put :update, id: role, role: attributes_for(:role, role_appointments_attributes_for(
      { role_appointment: role_appointment, person: nil, started_at: "2010-06-15", ended_at: "2011-07-23" },
      { person: nil, started_at: nil }
    ))

    assert_select "form#role_edit" do
      assert_select ".previous.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
        assert_select_role_appointment_date_select 0, "ended_at", [2011, 7, 23]
      end
      assert_select ".new.appointment", count: 1
    end
  end

  test 'update with invalid appointment data and populated new appointment should not lose or duplicate the appointment fields or values' do
    role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: role)
    person = create(:person, name: "person-name")

    put :update, id: role, role: attributes_for(:role, role_appointments_attributes_for(
      { role_appointment: role_appointment, person: nil, started_at: "2010-06-15", ended_at: "2011-07-23" },
      { person: person, started_at: "2011-08-31" }
    ))

    assert_select "form#role_edit" do
      assert_select ".previous.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][0][person_id]']"
        assert_select_role_appointment_date_select 0, "started_at", [2010, 6, 15]
        assert_select_role_appointment_date_select 0, "ended_at", [2011, 7, 23]
      end

      assert_select ".new.appointment", count: 1 do
        assert_select "select[name='role[role_appointments_attributes][1][person_id]']" do
          assert_select "option[selected='selected']", text: "person-name"
        end
        assert_select_role_appointment_date_select 1, "started_at", [2011, 8, 31]
      end
    end
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

  private

  def role_appointments_attributes_for(*appointments)
    result = {}
    appointments.each_with_index do |appointment, index|
      result[index.to_s] = {
        id: appointment[:role_appointment] ? appointment[:role_appointment].id : "",
        person_id: appointment[:person] ? appointment[:person].id : "",
        "started_at(1i)" => appointment[:started_at] ? Date.parse(appointment[:started_at]).year : "",
        "started_at(2i)" => appointment[:started_at] ? Date.parse(appointment[:started_at]).month : "",
        "started_at(3i)" => appointment[:started_at] ? Date.parse(appointment[:started_at]).day : "",
        "ended_at(1i)" => appointment[:ended_at] ? Date.parse(appointment[:ended_at]).year : "",
        "ended_at(2i)" => appointment[:ended_at] ? Date.parse(appointment[:ended_at]).month : "",
        "ended_at(3i)" => appointment[:ended_at] ? Date.parse(appointment[:ended_at]).day : "",
        _destroy: appointment[:_destroy]
      }
    end
    {role_appointments_attributes: result}
  end

  def assert_select_role_appointment_date_select(child_index, attribute_name, date)
    (0..2).each do |index|
      assert_select "select[name='role[role_appointments_attributes][#{child_index}][#{attribute_name}(#{index + 1}i)]']" do
        assert_select "option[selected='selected'][value='#{date[index]}']" if date[index].present?
      end
    end
  end
end