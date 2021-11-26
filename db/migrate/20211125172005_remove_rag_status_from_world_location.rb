class RemoveRagStatusFromWorldLocation < ActiveRecord::Migration[6.1]
  def up
    remove_column :world_locations, :coronavirus_watchlist_rag_status if column_exists? :world_locations, :coronavirus_watchlist_rag_status
    remove_column :world_locations, :coronavirus_next_rag_status if column_exists? :world_locations, :coronavirus_next_rag_status
    remove_column :world_locations, :coronavirus_next_rag_applies_at if column_exists? :world_locations, :coronavirus_next_rag_applies_at

    add_column :world_locations, :coronavirus_required_tests, :text
  end

  def down
    change_table :world_locations, bulk: true do |t|
      t.string :coronavirus_rag_status
      t.string :coronavirus_watchlist_rag_status
      t.string :coronavirus_next_rag_status
      t.datetime :coronavirus_next_rag_applies_at
    end

    remove_column :world_locations, :coronavirus_required_tests
  end
end
