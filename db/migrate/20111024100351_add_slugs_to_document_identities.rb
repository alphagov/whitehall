class AddSlugsToDocumentIdentities < ActiveRecord::Migration
  def change
    add_column :document_identities, :slug, :string
    add_index :document_identities, :slug, unique: true
  end
end