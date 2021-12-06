class RemoveCoronavirusWatchlistRagStatusFromWorldLocations < ActiveRecord::Migration[6.1]
  def up
    remove_column :world_locations, :coronavirus_watchlist_rag_status, :string
  end

  def down
    add_column :world_locations, :coronavirus_watchlist_rag_status, :string
  end
end
