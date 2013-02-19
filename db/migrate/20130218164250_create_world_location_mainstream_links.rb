class CreateWorldLocationMainstreamLinks < ActiveRecord::Migration
  def up
    create_table :world_location_mainstream_links do |t|
      t.references :world_location
      t.references :mainstream_link
    end
  end

  def down
    drop_table :world_location_mainstream_links
  end
end
