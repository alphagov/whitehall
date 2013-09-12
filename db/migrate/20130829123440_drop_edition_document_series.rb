class DropEditionDocumentSeries < ActiveRecord::Migration
  def up
    drop_table :edition_document_series
  end
end
