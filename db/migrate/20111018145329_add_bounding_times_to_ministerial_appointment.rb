class AddBoundingTimesToMinisterialAppointment < ActiveRecord::Migration
  def change
    add_column :ministerial_appointments, :started_at, :time
    add_column :ministerial_appointments, :ended_at, :time, default: nil

    MinisterialAppointment.update_all(started_at: 2.years.ago)
  end
end