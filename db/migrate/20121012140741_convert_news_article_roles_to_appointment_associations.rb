class ConvertNewsArticleRolesToAppointmentAssociations < ActiveRecord::Migration
  class Edition < ActiveRecord::Base
  end

  class RoleAppointment < ActiveRecord::Base
    CURRENT_CONDITION = {ended_at: nil}
  end

  class MinisterialRole < ActiveRecord::Base
    self.table_name = "roles"
    has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION
  end

  class EditionMinisterialRole < ActiveRecord::Base
    belongs_to :edition
    belongs_to :ministerial_role
  end

  class EditionRoleAppointment < ActiveRecord::Base
    belongs_to :edition
    belongs_to :role_appointment
  end

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
