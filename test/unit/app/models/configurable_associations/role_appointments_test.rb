require "test_helper"

class RoleAppointmentsRenderingTest < ActionView::TestCase
  test "it renders role appointments form control" do
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = build(:draft_standard_edition)
    config = {
      "key" => "role_appointments",
      "label" => "Ministers",
    }
    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
    render role_appointments_association
    assert_dom "label", text: config["label"]
    appointments.each do |appointment|
      assert_dom "option", text: [appointment.person.name, appointment.role.name, appointment.organisations.map(&:name).to_sentence].join(", ")
    end
  end

  test "it renders role appointments form control with pre-selected options" do
    config = {
      "key" => "role_appointments",
      "label" => "Ministers",
    }
    configurable_document_type = build_configurable_document_type("test_type", { "associations" => [config] })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = create(:draft_standard_edition, { role_appointments: [appointments.first] })

    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
    render role_appointments_association
    assert_dom "option[selected]", text: [appointments.first.person.name, appointments.first.role.name, appointments.first.organisations.map(&:name).to_sentence].join(", ")
    assert_not_dom "option[selected]", text: [appointments.last.person.name, appointments.last.role.name, appointments.last.organisations.map(&:name).to_sentence].join(", ")
  end
end
