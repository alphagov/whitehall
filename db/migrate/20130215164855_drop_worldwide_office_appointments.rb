class DropWorldwideOfficeAppointments < ActiveRecord::Migration
  def change
    drop_table :worldwide_office_appointments
  end
end
