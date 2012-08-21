class ChangeDocumentCollectionToDocumentSeries < ActiveRecord::Migration
  def up
    drop_table :edition_document_collections
    rename_table :document_collections, :document_series
    add_column :editions, :document_series_id, :integer
  end

  def down
    remove_column :editions, :document_series_id
    rename_table :document_series, :document_collections
    create_table :edition_document_collections, force: true do |t|
      t.references :edition
      t.references :document_collection
      t.timestamps
    end
  end
end
