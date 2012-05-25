class RenameDocumentOrganisationsToEditionOrganisations < ActiveRecord::Migration
  def change
    remove_index :document_organisations, [:edition_id, :organisation_id]
    remove_index :document_organisations, :organisation_id

    rename_table :document_organisations, :edition_organisations

    add_index :edition_organisations, [:edition_id, :organisation_id], unique: true
    add_index :edition_organisations, :organisation_id
  end
end
