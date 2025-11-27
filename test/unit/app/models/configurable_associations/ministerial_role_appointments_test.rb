require "test_helper"

class MinisterialRoleAppointmentsTest < ActiveSupport::TestCase
  test "it presents the selected role appointment links" do
    appointments = create_list(:ministerial_role_appointment, 3)
    edition = build(:draft_standard_edition)
    edition.role_appointments << [appointments.first, appointments.last]
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    expected_links = {
      people: [appointments.first.person.content_id, appointments.last.person.content_id],
      roles: [appointments.first.role.content_id, appointments.last.role.content_id],
    }
    assert_equal expected_links, role_appointments_association.links
  end

  test "it avoids sending duplicate people in the links when more than one role appointment is held by the same person" do
    person = create(:person)
    role1 = create(:ministerial_role)
    role2 = create(:ministerial_role)
    appointment1 = create(:ministerial_role_appointment, person: person, role: role1)
    appointment2 = create(:ministerial_role_appointment, person: person, role: role2)

    edition = build(:draft_standard_edition)
    edition.role_appointments << [appointment1, appointment2]
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    expected_links = {
      people: [person.content_id],
      roles: [role1.content_id, role2.content_id],
    }
    assert_equal expected_links, role_appointments_association.links
  end

  test "it avoids sending duplicate role IDs in case there is more than one appointment for the same role" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    person = create(:person)
    role = create(:ministerial_role)
    appointment1 = create(:ministerial_role_appointment, person: person, role: role)
    appointment2 = build(:ministerial_role_appointment, person: person, role: role)
    appointment2.content_id = SecureRandom.uuid #  for the presenter to work
    appointment2.save!(validate: false) # bypass 'overlap' validation

    edition = create(:draft_standard_edition)
    edition.role_appointments << [appointment1, appointment2]
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    expected_links = {
      people: [person.content_id],
      roles: [role.content_id],
    }
    assert_equal expected_links, role_appointments_association.links
  end
end

class MinisterialRoleAppointmentsRenderingTest < ActionView::TestCase
  test "it renders role appointments form control" do
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = build(:draft_standard_edition)
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    render role_appointments_association
    assert_dom "label", text: "Ministers"
    appointments.each do |appointment|
      assert_dom "option", text: [appointment.person.name, appointment.role.name, appointment.organisations.map(&:name).to_sentence].join(", ")
    end
  end

  test "it renders role appointments form control with pre-selected options" do
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = build(:draft_standard_edition, { role_appointments: [appointments.first] })

    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    render role_appointments_association
    assert_dom "option[selected]", text: [appointments.first.person.name, appointments.first.role.name, appointments.first.organisations.map(&:name).to_sentence].join(", ")
    assert_not_dom "option[selected]", text: [appointments.last.person.name, appointments.last.role.name, appointments.last.organisations.map(&:name).to_sentence].join(", ")
  end

  test "it renders role appointments for control with only ministerial appointments as options" do
    ministerial_appointments = create_list(:ministerial_role_appointment, 2)
    other_role_appointments = create_list(:judge_role_appointment, 2)
    edition = build(:draft_standard_edition)
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    render role_appointments_association
    assert_dom "label", text: "Ministers"
    ministerial_appointments.each do |appointment|
      assert_dom "option", text: [appointment.person.name, appointment.role.name, appointment.organisations.map(&:name).to_sentence].join(", ")
    end
    other_role_appointments.each do |appointment|
      assert_not_dom "option", text: [appointment.person.name, appointment.role.name, appointment.organisations.map(&:name).to_sentence].join(", ")
    end
  end
end
