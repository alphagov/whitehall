class AddDocumentSeriesCounterCacheToEditions < ActiveRecord::Migration
  def up
    add_column :editions, :document_series_count, :integer, null: false, default: 0
  end
end
