class DropContentBlockManagerTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :content_block_versions, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.string "item_type", null: false
      t.integer "item_id", null: false
      t.integer "event", null: false
      t.string "whodunnit"
      t.datetime "created_at", precision: nil, null: false
      t.text "state"
      t.json "field_diffs"
      t.string "updated_embedded_object_type"
      t.string "updated_embedded_object_title"
      t.index %w[item_id], name: "index_content_block_versions_on_item_id"
      t.index %w[item_type], name: "index_content_block_versions_on_item_type"
    end

    drop_table :content_block_edition_authors, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "edition_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index %w[edition_id], name: "index_content_block_edition_authors_on_edition_id"
      t.index %w[user_id], name: "index_content_block_edition_authors_on_user_id"
    end

    drop_table :content_block_edition_organisations, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "content_block_edition_id", null: false
      t.integer "organisation_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index %w[content_block_edition_id], name: "idx_on_content_block_edition_id_e433bc9b13"
      t.index %w[organisation_id], name: "index_content_block_edition_organisations_on_organisation_id"
    end

    drop_table :content_block_editions, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.json "details", null: false
      t.bigint "document_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "state", default: "draft", null: false
      t.datetime "scheduled_publication", precision: nil
      t.text "instructions_to_publishers"
      t.string "title", default: "", null: false
      t.text "internal_change_note"
      t.text "change_note"
      t.boolean "major_change"
      t.virtual "details_for_indexing", type: :text, as: "json_unquote(`details`)", stored: true
      t.index %w[document_id], name: "index_content_block_editions_on_document_id"
      t.index %w[title details_for_indexing instructions_to_publishers], name: "title_details_instructions_to_publishers", type: :fulltext
    end

    drop_table :content_block_documents, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.string "content_id"
      t.string "sluggable_string"
      t.string "block_type"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.integer "latest_edition_id"
      t.integer "live_edition_id"
      t.string "content_id_alias"
      t.datetime "deleted_at"
      t.index %w[content_id_alias], name: "index_content_block_documents_on_content_id_alias", unique: true
      t.index %w[latest_edition_id], name: "index_content_block_documents_on_latest_edition_id"
      t.index %w[live_edition_id], name: "index_content_block_documents_on_live_edition_id"
    end
  end
end
