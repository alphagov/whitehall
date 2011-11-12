require 'test_helper'

class Admin::RolesHelperTest < ActionView::TestCase
  test "unsaved role appointment is a new appointment" do
    role_appointment = build(:role_appointment)
    assert_equal "New Appointment", role_appointment_type(role_appointment)
  end

  test "saved role appointment without ended_at is a current appointment" do
    role_appointment = create(:role_appointment, started_at: 1.year.ago, ended_at: nil)
    assert_equal "Current Appointment", role_appointment_type(role_appointment)
  end

  test "saved role appointment with ended_at is previous appointment" do
    role_appointment = create(:role_appointment, started_at: 1.year.ago, ended_at: 1.day.ago)
    assert_equal "Previous Appointment", role_appointment_type(role_appointment)
  end
end
