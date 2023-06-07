require "test_helper"

class Admin::RoleAppointmentsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user(:writer)
  end

  should_be_an_admin_controller
  should_render_bootstrap_implementation_with_preview_next_release

  view_test "new should display a form for creating an appointment" do
    role = create(:role)
    get :new, params: { role_id: role.id }
    assert_select "form[action=?]", admin_role_role_appointments_path(role)
  end

  view_test "new should display a form for creating an appointment that will curtail the previous appointment if make_current is set" do
    role = create(:role)
    get :new, params: { role_id: role.id, make_current: true }
    assert_select "form[action=?]", admin_role_role_appointments_path(role) do
      assert_select "input[name='role_appointment[make_current]'][value=true]"
    end
  end

  view_test "new should display a form for creating new an appoint, with started_at set to today, if make_current is set" do
    role = create(:role)
    get :new, params: { role_id: role.id, make_current: true }
    assert_select "form[action=?]", admin_role_role_appointments_path(role) do
      assert_select "input[name='role_appointment[make_current]']"
      assert_select "select[name='role_appointment[started_at(1i)]'] option[value='#{Time.zone.today.year}'][selected='selected']"
      assert_select "select[name='role_appointment[started_at(2i)]'] option[value='#{Time.zone.today.month}'][selected='selected']"
      assert_select "select[name='role_appointment[started_at(3i)]'] option[value='#{Time.zone.today.day}'][selected='selected']"
    end
  end

  view_test "new should display a form for creating a historical appointment if make_current is not set" do
    role = create(:role)
    get :new, params: { role_id: role.id }
    assert_select "form[action=?]", admin_role_role_appointments_path(role) do
      assert_select "input[name='role_appointment[make_current]']", false
    end
  end

  test "create should create a new appointment" do
    role = create(:role)
    person = create(:person)
    post :create, params: { role_id: role.id, role_appointment: { person_id: person.id, started_at: 3.days.ago } }
    new_appointment = role.role_appointments.first
    assert_equal person, new_appointment.person
    assert_equal 3.days.ago, new_appointment.started_at
  end

  test "create redirects to the role edit form on success with a flash message" do
    role = create(:role)
    person = create(:person)
    post :create, params: { role_id: role.id, role_appointment: { person_id: person.id, started_at: 3.days.ago } }
    assert_redirected_to edit_admin_role_path(role)
    assert_equal "Appointment created", flash[:notice]
  end

  view_test "create should show any errors when creating the appointment" do
    role = create(:role)
    _person = create(:person)
    post :create, params: { role_id: role.id, role_appointment: { started_at: 3.days.ago } }
    assert role.role_appointments.empty?
    assert_select ".govuk-error-message", text: "Error: Person can't be blank"
  end

  test "create should curtail previous appointments if make_current is present" do
    role = create(:role)
    _previous_appointment = create(:role_appointment, role:, started_at: 10.days.ago)
    person = create(:person)
    post :create, params: { role_id: role.id, role_appointment: { person_id: person.id, started_at: 3.days.ago, make_current: true } }
    assert_equal person, role.current_person
  end

  view_test "edit should display an editing form for an existing appointment" do
    appointment = create(:role_appointment)
    get :edit, params: { id: appointment.id }
    assert_select "form[action=?]", admin_role_appointment_path(appointment)
  end

  view_test "edit should show a link to delete an appointment" do
    destroyable_appointment = create(:role_appointment)
    get :edit, params: { id: destroyable_appointment.id }
    assert_select "a[href=?]", confirm_destroy_admin_role_appointment_path(destroyable_appointment), text: "Delete"
  end

  view_test "edit should not show a link to delete an undeleteable appointment" do
    appointment = create(:role_appointment)
    create(:speech, title: "Some Speech", role_appointment: appointment)
    get :edit, params: { id: appointment.id }
    refute_select "a[href=?]", confirm_destroy_admin_role_appointment_path(appointment), text: "Delete"
  end

  view_test "edit should show speeches associated with this appointment" do
    appointment = create(:role_appointment)
    create(:speech, title: "Some Speech", role_appointment: appointment)
    get :edit, params: { id: appointment.id }
    assert_select ".speeches", text: /Some Speech/
  end

  view_test "edit should not allow the person to be changed" do
    appointment = create(:role_appointment)
    get :edit, params: { id: appointment.id }
    assert_select "select#role_appointment_person_id" do
      assert_select "option", count: 1
    end
  end

  test "update should update an existing role appointment" do
    appointment = create(:role_appointment, started_at: 3.days.ago, ended_at: 2.days.ago)
    put :update, params: { id: appointment.id, role_appointment: { ended_at: 1.day.ago } }
    assert_equal 1.day.ago, appointment.reload.ended_at
  end

  test "update should redirect to role edit form on success with a flash message" do
    appointment = create(:role_appointment, started_at: 3.days.ago, ended_at: 2.days.ago)
    put :update, params: { id: appointment.id, role_appointment: { ended_at: 1.day.ago } }
    assert_redirected_to edit_admin_role_path(appointment.role)
    assert_equal "Appointment has been updated", flash[:notice]
  end

  view_test "update shows errors if validation failed" do
    appointment = create(:role_appointment, started_at: 3.days.ago, ended_at: 2.days.ago)
    put :update, params: { id: appointment.id, role_appointment: { started_at: 1.day.from_now } }
    assert_select ".govuk-error-message", text: "Error: Started at should not be in the future"
  end

  view_test "confirm_destroy should display form for deleting an existing appointment" do
    appointment = create(:role_appointment)

    get :confirm_destroy, params: { id: appointment }

    assert_select "form[action='#{admin_role_appointment_path(appointment)}']" do
      assert_select "button[type='submit']", "Delete"
      assert_select "a[href=?]", admin_role_appointment_path(appointment).to_s, "Cancel"
    end
  end

  test "delete removes an appointment" do
    appointment = create(:role_appointment)
    delete :destroy, params: { id: appointment.id }
    assert_nil RoleAppointment.find_by(id: appointment.id)
  end

  test "delete redirects to role edit form on success with a flash message" do
    appointment = create(:role_appointment)
    delete :destroy, params: { id: appointment.id }
    assert_redirected_to edit_admin_role_path(appointment.role)
    assert_equal "Appointment has been deleted", flash[:notice]
  end

  test "delete refuses to remove an appointment that cannot be deleted" do
    appointment = create(:role_appointment)
    create(:speech, role_appointment: appointment)
    delete :destroy, params: { id: appointment.id }
    assert_equal appointment, appointment.reload, "appointment should still be in the database"
    assert_equal "Appointment can not be deleted", flash[:alert]
  end
end
