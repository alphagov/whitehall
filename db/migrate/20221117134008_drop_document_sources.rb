class DropDocumentSources < ActiveRecord::Migration[7.0]
  def change
    drop_table :document_sources do |t|
      t.integer "document_id"
      t.string "url", null: false
      t.integer "import_id"
      t.integer "row_number"
      t.string "locale", default: "en"
      t.index %w[document_id], name: "index_document_sources_on_document_id"
      t.index %w[url], name: "index_document_sources_on_url", unique: true
    end
  end
end
