class ChangeMinisterialAppointmentsBoundsToDatetimes < ActiveRecord::Migration
  class MinisterialAppointmentTable < ActiveRecord::Base
    self.table_name = "ministerial_appointments"
  end

  def change
    change_column :ministerial_appointments, :started_at, :datetime
    change_column :ministerial_appointments, :ended_at, :datetime, default: nil

    MinisterialAppointmentTable.update_all(started_at: 2.years.ago)
  end
end
