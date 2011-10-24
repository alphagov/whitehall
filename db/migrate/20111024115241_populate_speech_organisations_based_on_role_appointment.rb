class PopulateSpeechOrganisationsBasedOnRoleAppointment < ActiveRecord::Migration
  def change
    insert %{
      INSERT INTO document_organisations (document_id, organisation_id, created_at, updated_at)
        SELECT documents.id, organisation_roles.organisation_id, role_appointments.created_at, role_appointments.updated_at
          FROM documents
          INNER JOIN role_appointments ON role_appointments.id = documents.role_appointment_id
          INNER JOIN roles ON roles.id = role_appointments.role_id
          INNER JOIN organisation_roles ON organisation_roles.role_id = roles.id
          WHERE documents.type = 'Speech'
    }
  end
end
