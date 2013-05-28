module RoleAppointmentsHelper
  def create_role_appointment(person_name, role_name, organisation_name, timespan, options = {})
    person = find_or_create_person(person_name)
    organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
    role = MinisterialRole.create!({name: role_name}.merge(options[:role_options] || {}))
    organisation.ministerial_roles << role

    if timespan.is_a?(Hash)
      started_at = timespan.keys.first
      ended_at = timespan.values.first
    else
      started_at = timespan
      ended_at = nil
    end

    create(:role_appointment, role: role, person: person, started_at: started_at, ended_at: ended_at)
  end

  def find_or_create_ministerial_role(name)
    MinisterialRole.find_by_name(name) || create(:ministerial_role, name: name)
  end  
end

World(RoleAppointmentsHelper)
