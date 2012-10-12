class ConvertNewsArticleRolesToAppointmentAssociations < ActiveRecord::Migration
  def up
    old_role_associations = EditionMinisterialRole.joins("join editions e on e.id = edition_id").where("e.type = 'NewsArticle'")
    old_role_associations.each do |emr|
      emr.ministerial_role.current_role_appointments.each do |role_appointment|
        EditionRoleAppointment.create! edition: emr.edition, role_appointment: role_appointment
      end
      emr.destroy
    end
  end

  def down
  end
end
