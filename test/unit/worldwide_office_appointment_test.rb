require 'test_helper'

class WorldwideOfficeAppointmentTest < ActiveSupport::TestCase
  test "should be invalid without a worldwide office" do
    appointment = build(:worldwide_office_appointment, worldwide_office_id: nil)
    refute appointment.valid?
  end

  test "should be invalid without a job title" do
    appointment = build(:worldwide_office_appointment, job_title: nil)
    refute appointment.valid?
  end
end
