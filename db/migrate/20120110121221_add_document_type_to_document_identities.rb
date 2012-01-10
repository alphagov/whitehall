class AddDocumentTypeToDocumentIdentities < ActiveRecord::Migration
  def change
    remove_index :document_identities, :slug
    add_column :document_identities, :document_type, :string
    add_index :document_identities, [:slug, :document_type], unique: true
  end
end