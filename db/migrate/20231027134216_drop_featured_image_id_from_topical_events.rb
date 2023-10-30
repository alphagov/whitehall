class DropFeaturedImageIdFromTopicalEvents < ActiveRecord::Migration[7.0]
  def change
    remove_column :topical_events, :featured_image_data_id, :bigint
  end
end
