class AddEditionDocumentSeries < ActiveRecord::Migration
  def up
    create_table :edition_document_series do |t|
      t.references :edition, null: false
      t.references :document_series, null: false
    end
    add_index(:edition_document_series,
        [:edition_id, :document_series_id], unique: true,
        name: "index_edition_document_series")
  end

  def down
    drop_table :edition_document_series
  end
end
