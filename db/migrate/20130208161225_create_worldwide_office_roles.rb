class CreateWorldwideOfficeRoles < ActiveRecord::Migration
  def change
    create_table :worldwide_office_roles do |t|
      t.references :worldwide_office
      t.references :role
      t.timestamps
    end

    add_index :worldwide_office_roles, :worldwide_office_id
    add_index :worldwide_office_roles, :role_id
  end
end
