class RenameMinisterialAppointmentsToRoleAppointments < ActiveRecord::Migration
  def change
    rename_table :ministerial_appointments, :role_appointments
    rename_column :role_appointments, :ministerial_role_id, :role_id
  end
end
