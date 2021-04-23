class AddWorldLocationCoronavirusTravelStatus < ActiveRecord::Migration[6.0]
  def change
    change_table :world_locations, bulk: true do |t|
      t.string :coronavirus_rag_status
      t.string :coronavirus_watchlist_rag_status
      t.string :coronavirus_next_rag_status
      t.datetime :coronavirus_next_rag_applies_at
    end
  end
end
