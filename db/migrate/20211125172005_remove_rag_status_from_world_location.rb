class RemoveRagStatusFromWorldLocation < ActiveRecord::Migration[6.1]
  def change
    remove_column :world_locations, :coronavirus_watchlist_rag_status if column_exists? :world_locations, :coronavirus_watchlist_rag_status
    remove_column :world_locations, :coronavirus_next_rag_status if column_exists? :world_locations, :coronavirus_next_rag_status
    remove_column :world_locations, :coronavirus_next_rag_applies_at if column_exists? :world_locations, :coronavirus_next_rag_applies_at

    add_column :world_locations, :coronavirus_required_tests, :text
  end
end
