class DropSpecialistSectorsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table(:specialist_sectors, if_exists: true)
  end

  def down
    create_table "specialist_sectors", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
      t.integer "edition_id", null: false
      t.string "tag"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.boolean "primary", default: false
      t.string "topic_content_id"
      t.index %w[edition_id tag], name: "index_specialist_sectors_on_edition_id_and_tag", unique: true
    end
  end
end
