class CreateEditionRoleAppointments < ActiveRecord::Migration
  def change
    create_table :edition_role_appointments, force: true do |t|
      t.references :edition
      t.references :role_appointment
    end
  end
end
