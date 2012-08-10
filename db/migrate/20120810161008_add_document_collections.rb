class AddDocumentCollections < ActiveRecord::Migration
  def change
    create_table :document_collections do |t|
      t.string :name
      t.references :organisation
      t.timestamps
    end
  end
end
