class AddBoundingTimesToMinisterialAppointment < ActiveRecord::Migration
  class MinisterialAppointmentTable < ActiveRecord::Base
    set_table_name :ministerial_appointments
  end

  def change
    add_column :ministerial_appointments, :started_at, :time
    add_column :ministerial_appointments, :ended_at, :time, default: nil

    MinisterialAppointmentTable.update_all(started_at: 2.years.ago)
  end
end