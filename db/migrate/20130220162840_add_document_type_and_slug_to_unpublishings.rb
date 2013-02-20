class AddDocumentTypeAndSlugToUnpublishings < ActiveRecord::Migration
  def change
    add_column :unpublishings, :document_type, :string
    add_column :unpublishings, :slug, :string
  end
end
