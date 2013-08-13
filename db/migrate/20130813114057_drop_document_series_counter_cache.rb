class DropDocumentSeriesCounterCache < ActiveRecord::Migration
  def change
    remove_column :editions, :document_series_count
  end
end
