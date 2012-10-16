require 'test_helper'

class Edition::AppointmentTest< ActiveSupport::TestCase
  class EditionWithAppointment < Edition
    include ::Edition::Appointment
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title:   'edition-title',
      body:    'edition-body',
      creator: build(:user)
    }
  end

  setup do
    @edition = EditionWithAppointment.new(valid_edition_attributes.merge(role_appointment: build(:role_appointment)))
  end

  test "editions can be created with an appointment" do
    assert @edition.role_appointment
  end

  test "editions with appointment can access person" do
    assert @edition.person
  end

  test "editions with appointment enabled but not set aren't valid" do
    refute EditionWithAppointment.new(valid_edition_attributes).valid?
  end
end
