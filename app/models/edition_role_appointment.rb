# == Schema Information
#
# Table name: edition_role_appointments
#
#  id                  :integer          not null, primary key
#  edition_id          :integer
#  role_appointment_id :integer
#

class EditionRoleAppointment < ActiveRecord::Base
  belongs_to :edition
  belongs_to :role_appointment
end
