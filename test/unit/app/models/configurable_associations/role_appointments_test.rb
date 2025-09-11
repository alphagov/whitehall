require "test_helper"

class RoleAppointmentTest < ActiveSupport::TestCase
  test "the cache digest is updated when a role appointment is updated" do
    appointment = create(:ministerial_role_appointment)
    edition = build(:draft_standard_edition)
    config = {
      "key" => "role_appointments",
    }
    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
    digest = role_appointments_association.template_cache_digest

    assert_equal digest, role_appointments_association.template_cache_digest

    Timecop.freeze 1.hour.since do
      appointment.update!(ended_at: Time.zone.now)
    end

    assert_not_equal digest, role_appointments_association.template_cache_digest
  end
end

class RoleAppointmentsRenderingTest < ActionView::TestCase
  test "it renders role appointments form control" do
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = build(:draft_standard_edition)
    config = {
      "key" => "role_appointments",
    }
    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
    render role_appointments_association
    assert_dom "label", text: "Ministers"
    appointments.each do |appointment|
      assert_dom "option", text: [appointment.person.name, appointment.role.name, appointment.organisations.map(&:name).to_sentence].join(", ")
    end
  end

  test "it renders role appointments form control with pre-selected options" do
    config = {
      "key" => "role_appointments",
    }
    appointments = create_list(:ministerial_role_appointment, 2)
    edition = build(:draft_standard_edition, { role_appointments: [appointments.first] })

    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
    render role_appointments_association
    assert_dom "option[selected]", text: [appointments.first.person.name, appointments.first.role.name, appointments.first.organisations.map(&:name).to_sentence].join(", ")
    assert_not_dom "option[selected]", text: [appointments.last.person.name, appointments.last.role.name, appointments.last.organisations.map(&:name).to_sentence].join(", ")
  end

  test "it renders role appointments for control with only ministerial appointments as options" do
    ministerial_appointments = create_list(:ministerial_role_appointment, 2)
    other_role_appointments = create_list(:judge_role_appointment, 2)
    edition = build(:draft_standard_edition)
    config = {
      "key" => "role_appointments",
    }
    role_appointments_association = ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments)
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
