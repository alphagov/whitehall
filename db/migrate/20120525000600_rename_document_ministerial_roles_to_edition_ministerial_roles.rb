class RenameDocumentMinisterialRolesToEditionMinisterialRoles < ActiveRecord::Migration
  def change
    remove_index :document_ministerial_roles, :edition_id
    remove_index :document_ministerial_roles, :ministerial_role_id

    rename_table :document_ministerial_roles, :edition_ministerial_roles

    add_index :edition_ministerial_roles, :edition_id
    add_index :edition_ministerial_roles, :ministerial_role_id
  end
end
