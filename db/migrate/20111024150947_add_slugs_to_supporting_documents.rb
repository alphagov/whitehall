class AddSlugsToSupportingDocuments < ActiveRecord::Migration
  def change
    add_column :supporting_documents, :slug, :string
    add_index :supporting_documents, :slug
  end
end