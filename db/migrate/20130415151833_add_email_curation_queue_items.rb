class AddEmailCurationQueueItems < ActiveRecord::Migration
  def change
    create_table :email_curation_queue_items do |t|
      t.references :edition, null: false
      t.string :title
      t.text :summary
      t.datetime :notification_date
      t.timestamps
    end

    add_index :email_curation_queue_items, :edition_id
  end
end
