class RenameRolesToMinisterialRoles < ActiveRecord::Migration
  def change
    rename_table :roles, :ministerial_roles

    rename_table :document_roles, :document_ministerial_roles
    rename_column :document_ministerial_roles, :role_id, :ministerial_role_id

    rename_table :organisation_roles, :organisation_ministerial_roles
    rename_column :organisation_ministerial_roles, :role_id, :ministerial_role_id
  end
end