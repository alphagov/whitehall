class MinisterialAppointment < ActiveRecord::Base
  belongs_to :ministerial_role
  belongs_to :person
end