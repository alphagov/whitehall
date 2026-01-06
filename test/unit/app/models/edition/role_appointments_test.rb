require "test_helper"

class Edition::RoleAppointmentsTest < ActiveSupport::TestCase
  test "re-drafting an edition with role appointments copies the appointments" do
    appointments = [
      create(:role_appointment),
      create(:role_appointment),
    ]
    published = create(:published_publication, role_appointments: appointments)

    assert_equal appointments, published.create_draft(create(:user)).role_appointments
  end

  test "re-drafting a standard edition with role appointments copies the appointments" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    appointments = [
      create(:role_appointment),
      create(:role_appointment),
    ]
    published = create(:published_standard_edition, role_appointments: appointments)

    assert_equal appointments, published.create_draft(create(:user)).role_appointments
  end
end
