class AddMinisterialAppointments < ActiveRecord::Migration
  def change
    create_table :ministerial_appointments, force: true do |t|
      t.references :ministerial_role
      t.references :person
      t.timestamps
    end
    insert %{
      INSERT INTO ministerial_appointments (ministerial_role_id, person_id, created_at, updated_at)
        SELECT ministerial_roles.id, people.id, NOW(), NOW() FROM people
          INNER JOIN ministerial_roles ON ministerial_roles.person_id = people.id
    }
    remove_column :ministerial_roles, :person_id
  end
end
