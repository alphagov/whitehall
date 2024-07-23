class CreateContentBlockVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :content_block_versions do |t|
      t.string "item_type", index: true, null: false
      t.integer "item_id", index: true, null: false
      t.integer "event", null: false
      t.string "whodunnit"
      t.datetime "created_at", precision: nil, null: false
    end
  end
end
