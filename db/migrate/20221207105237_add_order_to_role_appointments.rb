class AddOrderToRoleAppointments < ActiveRecord::Migration[7.0]
  def change
    add_column :role_appointments, :order, :integer
  end
end
