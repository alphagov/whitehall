ActiveRecord::Base.logger = Logger.new(STDOUT)

helen_grant = Person.find_by_slug('helen-grant')
minister_for_sport_and_equality = Role.find_by_slug('parliamentary-under-secretary-of-state-sport-and-olympics') # Don't ask..

old_appointment = RoleAppointment.where(role_id: minister_for_sport_and_equality.id, person_id: helen_grant.id).first

minister_for_sport_tourism_and_equalities = MinisterialRole.create!(
  name: 'Minister for Sport, Tourism and Equalities',
  responsibilities: '',
  permanent_secretary: false,
  cabinet_member: false,
  chief_of_the_defence_staff: false,
  supports_historical_accounts: false,
  seniority: 100,
  whip_ordering: 100
)

new_appointment = RoleAppointment.create!(
  role_id: minister_for_sport_tourism_and_equalities.id,
  person_id: helen_grant.id,
  started_at: old_appointment.started_at
)

helen_grant.reload
minister_for_sport_tourism_and_equalities.reload

unless helen_grant.roles.include?(minister_for_sport_tourism_and_equalities) && minister_for_sport_tourism_and_equalities.people == [helen_grant]
  raise "Failed to assign Helen to the role of Minister for Sport, Tourism and Equalities"
end

previously_assigned_editions = old_appointment.editions.to_a

# Reassign speeches
ActiveRecord::Base.connection.update("
  UPDATE editions
  SET role_appointment_id = #{new_appointment.id}
  WHERE role_appointment_id = #{old_appointment.id}
")

# Reassign news articles & fatality notices
ActiveRecord::Base.connection.update("
  UPDATE edition_role_appointments
  SET role_appointment_id = #{new_appointment.id}
  WHERE role_appointment_id = #{old_appointment.id}
")

new_appointment.reload
raise "Failed to assign some new appointment editions" if new_appointment.editions != previously_assigned_editions

old_appointment.reload
raise "Failed to unassign some old appointment editions" if (old_appointment.editions & previously_assigned_editions).any?

old_appointment.delete
helen_grant.reload
raise "Failed to remove Helen from minister_for_sport_and_equality" if helen_grant.roles.include?(minister_for_sport_and_equality)

new_appointment.update_indexes
previously_assigned_editions.each(&:update_in_search_index)
