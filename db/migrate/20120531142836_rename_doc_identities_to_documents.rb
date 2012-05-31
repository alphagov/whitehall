class RenameDocIdentitiesToDocuments < ActiveRecord::Migration
  def change
    remove_index :doc_identities, [:slug, :document_type]
    rename_table :doc_identities, :documents
    add_index :documents, [:slug, :document_type], unique: true

    remove_index :edition_relations, :doc_identity_id
    rename_column :edition_relations, :doc_identity_id, :document_id
    add_index :edition_relations, :document_id

    remove_index :editions, :doc_identity_id
    rename_column :editions, :doc_identity_id, :document_id
    add_index :editions, :document_id

    remove_index :editions, :consultation_doc_identity_id
    rename_column :editions, :consultation_doc_identity_id, :consultation_document_id
    add_index :editions, :consultation_document_id
  end
end
