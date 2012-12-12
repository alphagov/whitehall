class AddUniqueIndexOnUrlToDocumentSources < ActiveRecord::Migration
  def change
    change_column_null :document_sources, :url, false
    add_index :document_sources, [:url], unique: true
  end
end
