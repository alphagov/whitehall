require 'test_helper'

class Edition::AppointmentTest< ActiveSupport::TestCase
  class EditionWithAppointment < Edition
    include ::Edition::Appointment

    def imported?
      state == 'imported'
    end
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

  test "editions with role appointment enabled but not set aren't valid" do
    refute EditionWithAppointment.new(valid_edition_attributes).valid?
  end

  test "editions allowed some invalid data don't have to have a role appointment" do
    EditionWithAppointment.new(valid_edition_attributes.merge(state: 'imported')).valid?
  end
end
