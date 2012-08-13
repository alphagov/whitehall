class AssociateEditionsWithDocumentCollections < ActiveRecord::Migration
  def change
    create_table :edition_document_collections, force: true do |t|
      t.references :edition
      t.references :document_collection
      t.timestamps
    end
  end
end
