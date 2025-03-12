require "test_helper"

class Edition::AppointmentTest < ActiveSupport::TestCase
  class EditionWithAppointment < GenericEdition
    include ::Edition::Appointment
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title: "edition-title",
      body: "edition-body",
      creator: build(:user),
    }
  end

  setup do
    @appointment = build(:role_appointment)
    document = build(:document)
    @edition = EditionWithAppointment.new(
      valid_edition_attributes.merge(
        role_appointment: @appointment,
        document:,
      ),
    )
  end

  test "editions can be created with an appointment" do
    assert @edition.role_appointment
  end

  test "editions with appointment can access person" do
    assert @edition.person
  end

  test "editions with appointment can access role" do
    assert @edition.role
  end

  test "editions with role appointment enabled but not set aren't valid" do
    assert_not EditionWithAppointment.new(valid_edition_attributes).valid?
  end
end
