class EditionRoleAppointment < ApplicationRecord
  belongs_to :edition
  belongs_to :role_appointment
end
