class RenameDocumentRelationsToEditionRelations < ActiveRecord::Migration
  def change
    remove_index :document_relations, :doc_identity_id
    remove_index :document_relations, :edition_id

    rename_table :document_relations, :edition_relations

    add_index :edition_relations, :doc_identity_id
    add_index :edition_relations, :edition_id
  end
end
