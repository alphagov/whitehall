require "test_helper"

class MinisterialRoleAppointmentsTest < ActiveSupport::TestCase
  test "it presents the selected role appointment links" do
    appointments = create_list(:ministerial_role_appointment, 3)
    edition = build(:draft_standard_edition)
    edition.role_appointments << [appointments.first, appointments.last]
    role_appointments_association = ConfigurableAssociations::MinisterialRoleAppointments.new(edition.role_appointments)
    expected_links = {
      role_appointments: [appointments.first.person.content_id, appointments.last.person.content_id],
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
