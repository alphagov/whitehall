class DropTableEmailCurationQueueItems < ActiveRecord::Migration
  def up
    drop_table :email_curation_queue_items
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
