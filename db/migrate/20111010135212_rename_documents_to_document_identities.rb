class RenameDocumentsToDocumentIdentities < ActiveRecord::Migration
  def change
    rename_table :documents, :document_identities
    rename_column :editions, :document_id, :document_identity_id
  end
end
