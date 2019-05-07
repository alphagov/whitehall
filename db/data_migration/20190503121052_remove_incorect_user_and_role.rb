matthew_purves = Person.where(surname: 'Purves', forename: 'Matthew').first
role = Role.where(name: 'Deputy Director, Schools').first
role_appt = matthew_purves.role_appointments.where(role_id: role.id).first

Services.publishing_api.patch_links('aa78b82f-e834-4c17-a9b9-66876fe46296', links: {'speaker' => []})
Services.publishing_api.unpublish(matthew_purves.content_id, type: 'gone')
Services.publishing_api.unpublish(role.content_id, type: 'gone')
Services.publishing_api.unpublish(role_appt.content_id, type: 'gone')

EditionRoleAppointment.where(role_appointment: role_appt).delete_all

role_appt.delete
role.delete
matthew_purves.delete
