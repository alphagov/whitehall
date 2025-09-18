require "test_helper"
require "rake"

class ReassignRoleAppointmentSpeechesTest < ActiveSupport::TestCase
  setup do
    @task = Rake::Task["data_hygiene:reassign_role_appointment_speeches"]
  end

  teardown do
    @task.reenable
  end

  test "it updates the role appointment ID on each speech to the new role appointment ID" do
    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)
    speeches = create_list(:speech, 3)
    old_role_appointment = create(:role_appointment)
    old_role_appointment.speeches = speeches
    new_role_appointment = create(:role_appointment)

    out, _err = capture_io { @task.invoke(old_role_appointment.id, new_role_appointment.id) }

    assert_equal new_role_appointment.speeches, old_role_appointment.speeches
    assert_empty old_role_appointment.reload.speeches
    assert_equal "Speeches reassigned to #{new_role_appointment.role_name}\n", out
  end

  test "it prints an error if the old role appointment ID does not exist" do
    old_role_appointment_id = 9999
    new_role_appointment = create(:role_appointment)

    _out, err = capture_io { @task.invoke(old_role_appointment_id, new_role_appointment.id) }
    assert_equal "Cannot find old role appointment: #{old_role_appointment_id}\n", err
  end

  test "it prints an error if the new role appointment ID does not exist" do
    old_role_appointment = create(:role_appointment)
    new_role_appointment_id = 9999

    _out, err = capture_io { @task.invoke(old_role_appointment.id, new_role_appointment_id) }
    assert_equal "Cannot find new role appointment: #{new_role_appointment_id}\n", err
  end

  test "it does not proceed to reassign the speeches for role appointments if the user declines" do
    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(false)
    speeches = create_list(:speech, 3)
    old_role_appointment = create(:role_appointment)
    old_role_appointment.speeches = speeches
    new_role_appointment = create(:role_appointment)

    capture_io { @task.invoke(old_role_appointment.id, new_role_appointment.id) }
    assert_empty new_role_appointment.reload.speeches
  end
end
