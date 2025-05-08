class DropTakePartPagesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :take_part_pages
  end

  def down
    create_table "take_part_pages", id: :integer, options: "DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
      t.string "title", null: false
      t.string "slug", null: false
      t.string "summary", null: false
      t.text "body", limit: 4_294_967_295, null: false # :long corresponds to `longtext` in MySQL
      t.string "image_alt_text"
      t.integer "ordering", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "content_id"
    end

    change_table :take_part_pages, bulk: true do |t|
      t.index :ordering, name: "index_take_part_pages_on_ordering"
      t.index :slug, name: "index_take_part_pages_on_slug", unique: true
    end
  end
end
