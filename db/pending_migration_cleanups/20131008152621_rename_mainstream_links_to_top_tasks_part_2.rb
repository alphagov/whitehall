class RenameMainstreamLinksToTopTasksPart2 < ActiveRecord::Migration
  def up
    drop_table :mainstream_links
    drop_table :world_location_mainstream_links
    drop_table :organisation_mainstream_links
  end

  def down
    create_table :mainstream_links do |t|
      t.string   "url"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "linkable_type"
      t.integer  "linkable_id"
    end
    add_index "mainstream_links", ["linkable_id", "linkable_type"]
    add_index "mainstream_links", ["linkable_type"]

    create_table "world_location_mainstream_links" do |t|
      t.integer "world_location_id"
      t.integer "mainstream_link_id"
    end
    add_index "world_location_mainstream_links", ["world_location_id"]

    create_table "organisation_mainstream_links" do |t|
      t.integer "organisation_id"
      t.integer "mainstream_link_id"
    end
    add_index "organisation_mainstream_links", ["organisation_id"]

    execute %Q{
      INSERT INTO mainstream_links(id, url, title, created_at, updated_at, linkable_type, linkable_id)
      SELECT id, url, title, created_at, updated_at, linkable_type, linkable_id
      FROM top_tasks
    }
    execute %Q{
      INSERT INTO world_location_mainstream_links(world_location_id, mainstream_link_id)
      SELECT world_location_id, top_task_id
      FROM world_location_top_tasks
    }
    execute %Q{
      INSERT INTO organisation_mainstream_links(organisation_id, mainstream_link_id)
      SELECT organisation_id, top_task_id
      FROM organisation_top_tasks
    }
  end
end
