class RemoveSlugFromDocuments < ActiveRecord::Migration[8.1]
  def change
    remove_index :documents, %w[slug document_type]
    safety_assured { remove_column :documents, :slug, :string }
  end
end
