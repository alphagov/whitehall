class EditionRoleAppointment < ActiveRecord::Base
  belongs_to :edition
  belongs_to :role_appointment
end
