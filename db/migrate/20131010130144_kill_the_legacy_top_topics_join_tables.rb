class KillTheLegacyTopTopicsJoinTables < ActiveRecord::Migration
  def up
    drop_table :world_location_top_tasks
    drop_table :organisation_top_tasks
    drop_table :topic_top_tasks
  end

  def down
    create_table "topic_top_tasks" do |t|
      t.integer "topic_id"
      t.integer "top_task_id"
    end
    add_index "topic_top_tasks", "topic_id"

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
      INSERT INTO topic_top_tasks(topic_id, top_task_id)
      SELECT linkable_id, id
      FROM top_tasks
      WHERE linkable_type = "Topic"
    }

    execute %Q{
      INSERT INTO world_location_top_tasks(world_location_id, top_task_id)
      SELECT linkable_id, id
      FROM top_tasks
      WHERE linkable_type = "WorldLocation"
    }

    execute %Q{
      INSERT INTO organisation_top_tasks(organisation_id, top_task_id)
      SELECT linkable_id, id
      FROM top_tasks
      WHERE linkable_type = "Organisation"
    }
  end
end
