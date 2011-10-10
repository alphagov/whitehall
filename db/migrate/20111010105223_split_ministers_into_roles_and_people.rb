class SplitMinistersIntoRolesAndPeople < ActiveRecord::Migration
  def change
    create_table :people, force: true do |t|
      t.string :name
      t.timestamps
    end
    remove_column :ministers, :name
    add_column :ministers, :person_id, :integer

    rename_table :ministers, :roles
    add_column :roles, :name, :string

    rename_table :edition_ministers, :edition_roles
    rename_column :edition_roles, :minister_id, :role_id
  end
end
