class RenameMainstreamLinksToTopTasksPart1 < ActiveRecord::Migration
  def up
    create_table :top_tasks do |t|
      t.string   "url"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "linkable_type"
      t.integer  "linkable_id"
    end
    add_index "top_tasks", ["linkable_id", "linkable_type"]
    add_index "top_tasks", ["linkable_type"]

    create_table "world_location_top_tasks" do |t|
      t.integer "world_location_id"
      t.integer "top_task_id"
    end
    add_index "world_location_top_tasks", ["world_location_id"]


    create_table "organisation_top_tasks" do |t|
      t.integer "organisation_id"
      t.integer "top_task_id"
    end
    add_index "organisation_top_tasks", ["organisation_id"]

    execute %Q{
      INSERT INTO top_tasks(url, title, created_at, updated_at, linkable_type, linkable_id)
      SELECT url, title, created_at, updated_at, linkable_type, linkable_id
      FROM mainstream_links
    }
    execute %Q{
      INSERT INTO world_location_top_tasks(world_location_id, top_task_id)
      SELECT world_location_id, mainstream_link_id
      FROM world_location_mainstream_links
    }
    execute %Q{
      INSERT INTO organisation_top_tasks(organisation_id, top_task_id)
      SELECT organisation_id, mainstream_link_id
      FROM organisation_mainstream_links
    }
  end

  def down
    drop_table :top_tasks
    drop_table :world_location_top_tasks
    drop_table :organisation_top_tasks
  end
end
