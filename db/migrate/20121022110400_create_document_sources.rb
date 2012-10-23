class CreateDocumentSources < ActiveRecord::Migration
  def change
    create_table :document_sources do |t|
      t.references :document
      t.string :url
    end
  end
end
