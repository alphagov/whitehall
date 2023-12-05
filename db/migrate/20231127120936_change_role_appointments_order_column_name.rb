class ChangeRoleAppointmentsOrderColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :role_appointments, :order, :ordering
  end
end
