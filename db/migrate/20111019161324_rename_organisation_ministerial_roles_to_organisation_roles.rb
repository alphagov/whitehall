class RenameOrganisationMinisterialRolesToOrganisationRoles < ActiveRecord::Migration
  def change
    rename_table :organisation_ministerial_roles, :organisation_roles
    rename_column :organisation_roles, :ministerial_role_id, :role_id
  end
end
