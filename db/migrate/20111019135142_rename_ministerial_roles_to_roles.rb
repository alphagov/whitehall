class RenameMinisterialRolesToRoles < ActiveRecord::Migration
  def change
    rename_table :ministerial_roles, :roles
    add_column :roles, :type, :string, default: 'MinisterialRole', null: false
  end
end
