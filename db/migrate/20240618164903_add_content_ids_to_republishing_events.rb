class AddContentIdsToRepublishingEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :republishing_events, :content_ids, :json
  end
end
