class AddContentIdToRoleAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :role_appointments, :content_id, :string
  end
end
