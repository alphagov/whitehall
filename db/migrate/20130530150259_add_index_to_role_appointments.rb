class AddIndexToRoleAppointments < ActiveRecord::Migration
  def change
    add_index :role_appointments, :ended_at
  end
end
