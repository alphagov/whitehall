class AddTimestampForSortingToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :timestamp_for_sorting, :datetime
    add_index :editions, :timestamp_for_sorting
    update %{
      UPDATE editions SET timestamp_for_sorting = first_published_at WHERE type <> 'Publication'
    }
    update %{
      UPDATE editions SET timestamp_for_sorting = publication_date WHERE type = 'Publication'
    }
  end
end