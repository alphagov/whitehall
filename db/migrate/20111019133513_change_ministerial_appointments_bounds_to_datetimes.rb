class ChangeMinisterialAppointmentsBoundsToDatetimes < ActiveRecord::Migration
  def change
    change_column :ministerial_appointments, :started_at, :datetime
    change_column :ministerial_appointments, :ended_at, :datetime, default: nil

    MinisterialAppointment.update_all(started_at: 2.years.ago)
  end
end
