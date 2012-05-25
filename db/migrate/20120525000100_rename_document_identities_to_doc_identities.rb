class RenameDocumentIdentitiesToDocIdentities < ActiveRecord::Migration
  def change
    remove_index :document_identities, name: "index_document_identities_on_slug_and_document_type"
    rename_table :document_identities, :doc_identities
    add_index "doc_identities", ["slug", "document_type"], name: "index_doc_identities_on_slug_and_document_type", unique: true

    remove_index :document_relations, name: "index_document_relations_on_document_identity_id"
    rename_column :document_relations, :document_identity_id, :doc_identity_id
    add_index "document_relations", ["doc_identity_id"], name: "index_document_relations_on_doc_identity_id"

    remove_index "documents", name: "index_documents_on_document_identity_id"
    rename_column :documents, :document_identity_id, :doc_identity_id
    add_index "documents", ["doc_identity_id"], name: "index_documents_on_doc_identity_id"

    remove_index "documents", name: "index_documents_on_consultation_document_identity_id"
    rename_column :documents, :consultation_document_identity_id, :consultation_doc_identity_id
    add_index "documents", ["consultation_doc_identity_id"], name: "index_documents_on_consultation_doc_identity_id"
  end
end
