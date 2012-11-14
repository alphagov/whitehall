class AddCorrectOrganisationToSpeeches < ActiveRecord::Migration
  class Edition < ActiveRecord::Base; end

  class Speech < Edition
    set_inheritance_column 'Speech'
    belongs_to :role_appointment
    delegate :role, to: :role_appointment

    has_many :edition_organisations, foreign_key: :edition_id, dependent: :destroy
    has_many :organisations, through: :edition_organisations

    def organisations_via_role_appointment
      role_appointment && role_appointment.role && role_appointment.role.organisations || []
    end
  end

  class RoleAppointment < ActiveRecord::Base
    has_many :edition_role_appointments
    has_many :editions, through: :edition_role_appointments
    belongs_to :role
  end

  class Role < ActiveRecord::Base
    has_many :role_appointments
    has_many :organisation_roles
    has_many :organisations, through: :organisation_roles
  end

  class Organisation < ActiveRecord::Base; end

  class EditionOrganisation < ActiveRecord::Base
    belongs_to :edition
    belongs_to :organisation
  end

  def up
    Speech.all.each do |speech|
      speech.organisations = []
      speech.organisations = speech.organisations_via_role_appointment
      speech.save!
    end
  end
end
